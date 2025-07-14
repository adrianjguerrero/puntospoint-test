class Client < User
  has_many :sales, foreign_key: :client_id, dependent: :destroy

end