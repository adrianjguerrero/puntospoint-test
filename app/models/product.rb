class Product < ApplicationRecord
  belongs_to :user

  
  validate :user_must_be_administrator

  private

  def user_must_be_administrator
    unless user.is_a?(Administrator)
      errors.add(:user, "must be an administrator")
    end
  end
end
