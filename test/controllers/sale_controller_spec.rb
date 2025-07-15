require "rails_helper"

RSpec.describe "Sales API", type: :request do
  describe "POST /sales" do
    let(:admin_user) { Administrator.create(email: "admin@example.com", password: "password") }
    let(:second_admin_user) { Administrator.create(email: "admin2@example.com", password: "password") }
    let(:product) { Product.create(name: "Test Product", stock: 1, price: 100, user: admin_user) }
    let(:product_mail) { Product.create(name: "Mail Product", stock: 2, price: 100, user: admin_user) }
    let(:sale_params) do
      {
        sale: [
          { product_id: product.id, quantity: 1 }
        ]
      }
    end
    let(:mail_sale_params) do
      {
        sale: [
          { product_id: product_mail.id, quantity: 1 }
        ]
      }
    end

    let(:user) { User.create(email: "test@example.com", password: "password") }
    let(:auth_token) do
      # log user
      post "/login", params: {
        user: {
          email: user.email,
          password: "password"
        }
      }, as: :json
      response.headers["Authorization"]
    end

    it "returns an error for the second request due to insufficient stock" do
      responses = []

      threads = []
      2.times do
        threads << Thread.new do
          post("/sales", params: sale_params, headers: { Authorization: auth_token })
          responses << response.dup
        end
      end

      threads.each(&:join)

      # check first response to success
      expect(responses.first.status).to eq(201)

      # check second response to failure becauses product didn't have stock
      expect(responses.last.status).to eq(422)
      expect(JSON.parse(responses.last.body)["error"]).to eq("Insufficient stock for product ID #{product.id}")

      product.reload
      expect(product.stock).to eq(0)

      expect(Sale.count).to eq(1)
    end

    it "sends an email only the first time a product is purchased, even in race conditions" do
      # clear emails before the test
      ActionMailer::Base.deliveries.clear

      threads = []
      2.times do
        threads << Thread.new do
          post "/sales", params: mail_sale_params, headers: { Authorization: auth_token }
        end
      end

      threads.each(&:join)

      # check that only one email was sent
      expect(ActionMailer::Base.deliveries.count).to eq(1)

      # check email content
      email = ActionMailer::Base.deliveries.first
      expect(email.to).to include(admin_user.email)
      expect(email.subject).to eq("Primer venta del producto: #{product_mail.name}")
    end
  end
end