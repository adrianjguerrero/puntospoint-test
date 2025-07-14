class Administrator < User
  has_many :products, foreign_key: :user_id, dependent: :destroy

end