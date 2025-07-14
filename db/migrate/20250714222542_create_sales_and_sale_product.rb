class CreateSalesAndSaleProduct < ActiveRecord::Migration[8.0]
  def change
    create_table :sales do |t|
      t.decimal :total, precision: 10, scale: 2, null: false
      t.string :status, null: false
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.integer :qty_products, null: false, default: 0
      t.timestamps
    end

    create_table :sale_products do |t|
      t.references :sale, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.timestamps
    end
  end
end
