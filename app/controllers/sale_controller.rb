class SaleController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorize


  def create
    cart = sale_params
    client_id = @current_user.id 
    if cart.blank? || !cart.is_a?(Array)
      render json: { error: 'Invalid cart data' }, status: :unprocessable_entity and return
    end

    @sale = Sale.new(client_id: client_id, total: 0, qty_products: 0, status: 'pending')

    ActiveRecord::Base.transaction do
      cart.each do |item|
        product = Product.find(item[:product_id])
        if product.stock < item[:quantity].to_i
          render json: { error: "Insufficient stock for product ID #{item[:product_id]}" }, status: :unprocessable_entity and return
        end

        product.stock -= item[:quantity].to_i
        product.save!

        product.with_lock do 

          if product.first_sale_product?

            creator = product.user

            other_admins = User.where(type: "Administrator").where.not(id: creator.id)

            AdminMailer.notify_first_sale(product, creator, other_admins).deliver_now
          end
        end

        @sale.sale_products.build(product: product, quantity: item[:quantity].to_i)

        @sale.total += product.price * item[:quantity].to_i
        @sale.qty_products += item[:quantity].to_i
      end

      @sale.save!
    end

    render json: { message: "Sale created successfully", sale: @sale }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def sale_params
    params.require(:sale).map do |item|
      item.permit(:product_id, :quantity)
    end
  end
end
