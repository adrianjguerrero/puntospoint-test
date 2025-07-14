class Product < ApplicationRecord
  belongs_to :user
  belongs_to :category

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
