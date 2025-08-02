class ProductsController < ApplicationController
  include ApplicationHelper
  before_action :set_product, only: [:show, :update, :destroy]
  before_action :authorize
  before_action :authenticate_admin!
  skip_before_action :verify_authenticity_token

  def index
    params[:page] = Integer(params[:page]) rescue 1
    @products = Product.paginate(page: params[:page], per_page: 2)
    render json: @products
  end

  def show
    render json: @product
  end

  def create
    permitted_params = product_params.except(:category_id)
    @product = Product.new(permitted_params)
    @product.user_id = current_administrator.id
    category = Category.find(product_params[:category_id])
    if category.nil?
      return render json: { error: 'Category not found' }, status: :not_found
    end
    @product.categories << category
    if @product.save
      log_audit('create', @product, current_administrator)
      render json: @product, status: :created
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    previous_data = @product.attributes.to_json
    if @product.update(product_params.except(:category_id))
      log_audit('update', @product, current_administrator, previous_data)
      render json: @product
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    log_audit('destroy', @product, current_administrator)
    @product.destroy
    head :no_content
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price, :stock, :sales_count, :category_id)
  end

end
