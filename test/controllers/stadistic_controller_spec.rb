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

    let(:create_sale_request) do
      ->(sale_params) { post "/sales", params: sale_params, headers: { Authorization: "Bearer " + auth_token } }
    end

    let(:category) { Category.create(name: "Most Sold Category") }
    let(:product1) { Product.create(name: "Product 1", stock: 10, price: 250, user: user) }
    let(:product2) { Product.create(name: "Product 2", stock: 5, price: 100, user: user) }
    let(:product3) { Product.create(name: "Product 3", stock: 8, price: 50, user: user) }
    let(:product4) { Product.create(name: "Product 4", stock: 15, price: 25, user: user) }
    let(:category_2) { Category.create(name: "Category 2") }
    before do
      product1.categories << category
      product2.categories << category
      product3.categories << category
      product4.categories << category_2
    end



    it "returns the most purchased products by category" do
      sale_params ={
        sale: [
          { product_id: product1.id, quantity: 5 },
          { product_id: product3.id, quantity: 2 },
          { product_id: product2.id, quantity: 1 },
        ]
      }

      create_sale_request.call(sale_params)
      get "/most_sold_products", headers: { Authorization: "Bearer "+auth_token }

      json_response = JSON.parse(response.body)

      # test we get the right response
      expect(json_response.keys[0]).to eq(category.name)
      expect(json_response[category.name][0]).to include("product_id" => product1.id)
      expect(json_response[category.name][1]).to include("product_id" => product3.id)
      expect(json_response[category.name][2]).to include("product_id" => product2.id)
    end

    it "returns the top revenue products" do
      sale_params ={
        sale: [
          { product_id: product2.id, quantity: 5 },
          { product_id: product1.id, quantity: 1 },
          { product_id: product3.id, quantity: 2 },
          { product_id: product4.id, quantity: 3 },
        ]
      }
      create_sale_request.call(sale_params)

      get "/top_revenue_products", headers: { Authorization: "Bearer " + auth_token }
      json_response = JSON.parse(response.body)

      expect(json_response.keys[0]).to eq(category.name)

      expect(json_response[category.name].length).to eq(3)

      expect(json_response[category.name][0]).to include("product_id" => product2.id)
      expect(json_response[category.name][1]).to include("product_id" => product1.id)
      expect(json_response[category.name][2]).to include("product_id" => product3.id)
    end

    it "returns sales filtered by category" do
      4.times do |i|
        params={ sale: [{ product_id: send("product#{i+1}").id, quantity: i+1 }] }
        create_sale_request.call(params)
      end
      get "/purchases_by_parameters", headers: { Authorization: "Bearer " + auth_token },
        params: {
          category_id: category_2.id
        }
      json_response = JSON.parse(response.body)

      # we only have one product in category_2
      expect(json_response.length).to eq(1)
    end


    it "returns sales grouped by granularity" do
      4.times do |i|
        params={ sale: [{ product_id: send("product#{i+1}").id, quantity: i+1 }] }
        create_sale_request.call(params)
      end
      get "/purchases_by_granularity", headers: { Authorization: "Bearer " + auth_token },
        params: {
          category_id: category.id,
          granularity: "day"
        }
      json_response = JSON.parse(response.body)
      current_time = Time.now.utc.strftime("%Y-%m-%d")

      # test we get the right format and qty of sales
      expect(json_response.keys[0]).to eq(current_time)
      expect(json_response[current_time]).to eq(3)
      expect(response).to be_successful
    end
  end
end
