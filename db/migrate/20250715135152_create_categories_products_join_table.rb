class CreateCategoriesProductsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table :categories_products do |t|
      t.references :product, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.timestamps
    end

    remove_reference :products, :category, foreign_key: true
  end
end
