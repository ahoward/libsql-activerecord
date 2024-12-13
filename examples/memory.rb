# frozen_string_literal: true

require 'libsql-activerecord'
require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'libsql')

class Product < ActiveRecord::Base
end

class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.timestamps
    end
  end
end

class AddDescription < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :description, :string
  end
end

CreateProducts.migrate(:up)
AddDescription.migrate(:up)

p = Product.new
p.name = 'Book'
p.description = 'A book about books'
p.save

Product.all.each do |product|
  product.destroy
end

p Product.all
