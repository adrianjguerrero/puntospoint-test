class Sale < ApplicationRecord
  belongs_to :client, class_name: "User", foreign_key: :client_id
  has_many :sale_products, dependent: :destroy
  has_many :products, through: :sale_products

  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
