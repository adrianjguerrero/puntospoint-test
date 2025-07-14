class ChangeTableProducts < ActiveRecord::Migration[8.0]
  def change
    
    add_reference :products, :category, null: false, foreign_key: true

    
    add_column :products, :sales_count, :integer, default: 0, null: false
  end
end
