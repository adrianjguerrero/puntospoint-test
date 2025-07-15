class Product < ApplicationRecord
  belongs_to :user
  has_many :sale_products, dependent: :destroy
  has_many :sales, through: :sale_products
  has_many :images, as: :imageable, dependent: :destroy
  
  has_many :categories_products, dependent: :destroy
  has_many :categories, through: :categories_products

  validate :user_must_be_administrator

  def increment_sales_count(quantity = 1)
    self.sales_count += quantity
    save
  end

  private

  def user_must_be_administrator
    unless user.is_a?(Administrator)
      errors.add(:user, "Must be an administrator")
    end
  end
end
