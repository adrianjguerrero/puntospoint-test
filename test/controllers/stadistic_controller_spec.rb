require "rails_helper"
RSpec.describe "Stadistic API", type: :request do
  describe "Stadistic Endpoints" do
    let(:user) { Administrator.create(email: "test@example.com", password: "password") }
    let(:auth_token) do
      # log user
      post "/login", params: {
        user: {
          email: user.email,
          password: user.password
        }
      }, as: :json
      JSON.parse(response.body)["token"]
    end

    let(:category) { Category.create(name: "Most Sold Category") }
    let(:product1) { Product.create(name: "Product 1", stock: 10, price: 250, user: user) }
    let(:product2) { Product.create(name: "Product 2", stock: 5, price: 100, user: user) }
    let(:product3) { Product.create(name: "Product 3", stock: 8, price: 50, user: user) }
    let(:product4) { Product.create(name: "Product 4", stock: 15, price: 300, user: user) }
    let(:product5) { Product.create(name: "Product 5", stock: 20, price: 150, user: user) }
    let(:category_2) { Category.create(name: "Category 2") }
    let(:sale_request) do
      post "/sales", params: 
      {
        sale: [
          { product_id: product1.id, quantity: 5 },
          { product_id: product2.id, quantity: 2 },
          { product_id: product3.id, quantity: 3 },
          { product_id: product5.id, quantity: 1 }
        ]
      }, headers: { Authorization: "Bearer " + auth_token }
    end
    before do
      product1.categories << category
      product2.categories << category
      product3.categories << category
      product4.categories << category_2
    end



    it "returns the most purchased products by category" do
      sale_request
      get "/most_sold_products", headers: { Authorization: "Bearer "+auth_token }

      json_response = JSON.parse(response.body)

      # test we get the right response
      expect(json_response.keys[0]).to eq(category.name)
      expect(json_response[category.name][0]).to include("product_id" => product1.id)
      expect(json_response[category.name][1]).to include("product_id" => product3.id)
      expect(json_response[category.name][2]).to include("product_id" => product2.id)
    end

    it "returns the top revenue products" do
      sale_request

      get "/top_revenue_products", headers: { Authorization: "Bearer " + auth_token }
      json_response = JSON.parse(response.body)

      expect(json_response.keys[0]).to eq(category.name)

      expect(json_response[category.name].length).to eq(3)

      expect(json_response[category.name][0]).to include("product_id" => product1.id)
      expect(json_response[category.name][1]).to include("product_id" => product2.id)
      expect(json_response[category.name][2]).to include("product_id" => product3.id)


      puts json_response.inspect
    end

    it "returns sales filtered by parameters" do
      get '/purchases_by_parameters', headers: { Authorization: "Bearer " + auth_token }
      expect(response).to be_successful
    end

  
    it "returns sales grouped by granularity" do
      get '/purchases_by_granularity', headers: { Authorization: "Bearer " + auth_token }
      expect(response).to be_successful
    end

      
  end
end
