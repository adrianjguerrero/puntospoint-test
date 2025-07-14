class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.integer :stock
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
