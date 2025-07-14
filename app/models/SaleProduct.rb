class SaleProduct < ApplicationRecord
  after_create :update_product_sales_count
  belongs_to :sale
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  private

  def update_product_sales_count
    self.product.increment_sales_count(self.quantity)
  end
end