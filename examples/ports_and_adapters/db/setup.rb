# frozen_string_literal: true

require 'active_support/all'

ActiveRecord::Base.establish_connection(
  host: 'localhost',
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.column :name, :string
    t.column :email, :string
  end
end
