require_relative '../lib/libsql-activerecord'

require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'libsql', path: "hello.db")

class Product < ActiveRecord::Base
end

# class CreateProducts < ActiveRecord::Migration[8.0]
#   def change
#     create_table :products do |t|
#       t.string :name
#       t.string :description
#       t.timestamps
#     end
#   end
# end

# CreateProducts.migrate(:up)

p = Product.new

p.name = 'Book'
p.description = 'A book about books'
p.save

Product.all.each do |product|
  p product
  puts product.name
end

RSpec.describe do
  it 'create, insert, select table' do
  end
end
