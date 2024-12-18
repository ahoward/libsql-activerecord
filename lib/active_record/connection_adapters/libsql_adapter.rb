# frozen_string_literal: true

require 'active_record'
require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'
require 'active_record/connection_adapters/sqlite3/database_statements'
require 'active_record/connection_adapters/sqlite3/schema_statements'
require 'active_record/connection_adapters/sqlite3/quoting'

require 'libsql'

module ActiveRecord
  class Base # :nodoc:
    class << self
      def libsql_connection(config)
        config = config.symbolize_keys
        connection = ::Libsql::Database.new config
        ConnectionAdapters::LibsqlAdapter.new(connection, logger, config)
      end
    end
  end

  module ConnectionAdapters # :nodoc:
    if ActiveRecord.version >= Gem::Version.new('7.2')
      register 'libsql', 'ActiveRecord::ConnectionAdapters::LibsqlAdapter',
               'active_record/connection_adapters/libsql_adapter'
    end

    class LibsqlAdapter < AbstractAdapter # :nodoc:
      ADAPTER_NAME = 'libSQL'

      NATIVE_DATABASE_TYPES = {
        primary_key: 'integer PRIMARY KEY AUTOINCREMENT NOT NULL',
        string: { name: 'varchar' },
        text: { name: 'text' },
        integer: { name: 'integer' },
        float: { name: 'float' },
        decimal: { name: 'decimal' },
        datetime: { name: 'datetime' },
        time: { name: 'time' },
        date: { name: 'date' },
        binary: { name: 'blob' },
        boolean: { name: 'boolean' },
        json: { name: 'json' }
      }.freeze

      READ_QUERY = AbstractAdapter.build_read_query_regexp(:pragma)
      private_constant :READ_QUERY

      def write_query?(sql) # :nodoc:
        !READ_QUERY.match?(sql)
      end

      def native_database_types # :nodoc:
        NATIVE_DATABASE_TYPES
      end

      class << self
        def new_client(config)
          db = Libsql::Database.new(config || {})
          db.connect
        end
      end

      def initialize(...)
        super
        @connection_parameters = @config.reject { |k| k == :adapter }
        @connection_parameters[:url] = @connection_parameters[:host]
      end

      def connect
        @raw_connection = self.class.new_client(@connection_parameters)
      end

      def reconnect
        @raw_connection&.close
        connect
      end

      def perform_query(
        raw_connection, sql, binds, type_casted_binds, prepare:,
        notification_payload:, batch: false
      )
        _ = prepare
        _ = notification_payload
        _ = binds

        if batch
          raw_connection.execute_batch(sql)
        else
          stmt = raw_connection.prepare(sql)
          begin
            result =
              if stmt.column_count.zero?
                @last_affected_rows = stmt.execute type_casted_binds
                ActiveRecord::Result.empty
              else
                rows = stmt.query(type_casted_binds)
                @last_affected_rows = nil
                ActiveRecord::Result.new(rows.columns, rows.to_a.map(&:values))
              end
          ensure
            stmt.close
          end
        end
        verified!

        result
      end

      def affected_rows(_result)
        @last_affected_rows
      end

      def cast_result(result)
        result
      end

      def quote_column_name(name)
        %("#{name.to_s.gsub('"', '""')}").freeze
      end

      def quote_table_name(name)
        %("#{name.to_s.gsub('"', '""').gsub('.', '"."')}").freeze
      end

      def column_definitions(table_name)
        internal_exec_query("PRAGMA table_xinfo(#{quote_table_name(table_name)})", 'SCHEMA')
      end

      def data_source_sql(name = nil, type: nil)
        scope = quoted_scope(name, type:)
        scope[:type] ||= "'table','view'"

        sql = +"SELECT name FROM pragma_table_list WHERE schema <> 'temp'"
        sql << " AND name NOT IN ('sqlite_sequence', 'sqlite_schema')"
        sql << " AND name = #{scope[:name]}" if scope[:name]
        sql << " AND type IN (#{scope[:type]})"
        sql
      end

      def quoted_scope(name = nil, type: nil)
        type = {
          'BASE_TABLE': "'table'",
          'VIEW': "'view'",
          'VIRTUAL TABLE': "'virtual'"
        }[type]

        scope = {}
        scope[:name] = quote(name) if name
        scope[:type] = type if type
        scope
      end

      def extract_value_from_default(default)
        case default
        when /^null$/i then nil
        when /^'([^|]*)'$/m then::Regexp.last_match(1).gsub("''", "'")
        when /^"([^|]*)"$/m then ::Regexp.last_match(1).gsub('""', '"')
        when /\A-?\d+(\.\d*)?\z/ then ::Regexp.last_match(0)
        when /x'(.*)'/ then [::Regexp.last_match(1)].pack('H*')
        end
      end

      def extract_default_function(default_value, default)
        default if default_function?(default_value, default)
      end

      def default_function?(default_value, default)
        !default_value && /\w+\(.*\)|CURRENT_TIME|CURRENT_DATE|CURRENT_TIMESTAMP|\|\|/.match?(default)
      end

      def extract_generated_type(field)
        case field['hidden']
        when 2 then :virtual
        when 3 then :stored
        end
      end

      def column_the_rowid?(field, column_definitions)
        return false unless /integer/i.match?(field['type']) && field['pk'] == 1

        column_definitions.one? { |c| c['pk'].positive? }
      end

      def new_column_from_field(_table_name, field, definitions)
        default = field['dflt_value']

        type_metadata = fetch_type_metadata(field['type'])
        default_value = extract_value_from_default(default)
        generated_type = extract_generated_type(field)

        default_function =
          if generated_type.present?
            default
          else
            extract_default_function(default_value, default)
          end

        rowid = column_the_rowid?(field, definitions)

        Column.new(
          field['name'],
          default_value,
          type_metadata,
          field['notnull'].to_i.zero?,
          default_function,
          collation: field['collation'],
          auto_increment: field['auto_increment'],
          rowid:,
          generated_type:
        )
      end

      def primary_keys(table_name) # :nodoc:
        column_definitions(table_name)
          .select { |f| f['pk'].positive? }
          .sort_by { |f| f['pk'] }
          .map { |f| f['name'] }
      end

      def last_inserted_id(result)
        @raw_connection.last_inserted_id
      end

      def indexes(table_name)
        internal_exec_query("PRAGMA index_list(#{quote_table_name(table_name)})", 'SCHEMA').filter_map do |row|
          # Indexes SQLite creates implicitly for internal use start with "sqlite_".
          # See https://www.sqlite.org/fileformat2.html#intschema
          next if row['name'].start_with?('sqlite_')

          index_sql = query_value(<<~SQL, 'SCHEMA')
            SELECT sql
            FROM sqlite_master
            WHERE name = #{quote(row['name'])} AND type = 'index'
            UNION ALL
            SELECT sql
            FROM sqlite_temp_master
            WHERE name = #{quote(row['name'])} AND type = 'index'
          SQL

          %r{\bON\b\s*"?(\w+?)"?\s*\((?<expressions>.+?)\)(?:\s*WHERE\b\s*(?<where>.+))?(?:\s*/\*.*\*/)?\z}i =~ index_sql

          columns = internal_exec_query("PRAGMA index_info(#{quote(row['name'])})", 'SCHEMA').map do |col|
            col['name']
          end

          where = where.sub(%r{\s*/\*.*\*/\z}, '') if where
          orders = {}

          if columns.any?(&:nil?) # index created with an expression
            columns = expressions
          elsif index_sql
            # Add info on sort order for columns (only desc order is explicitly specified,
            # asc is the default)
            index_sql.scan(/"(\w+)" DESC/).flatten.each do |order_column|
              orders[order_column] = :desc
            end # index_sql can be null in case of primary key indexes
          end

          IndexDefinition.new(
            table_name,
            row['name'],
            row['unique'] != 0,
            columns,
            where:,
            orders:
          )
        end
      end
    end
  end
end
