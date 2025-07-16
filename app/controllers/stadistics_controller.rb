class StadisticsController < ApplicationController
  before_action :authorize
  before_action :authenticate_admin!

  def most_purchased_products_by_category
    results = Category
    .select("categories.name AS category_name, products.id AS product_id, products.sales_count AS total_quantity")
    .joins(:products)
    .where(products: { id: Product.select("id")
      .where("category_id = categories.id")
      .order(sales_count: :desc)
      .limit(5)
    })
    .order("categories.name, products.sales_count DESC")
    .group_by(&:category_name)

    results = results.transform_values do |products|
      products.map do |product|
        {
          product_id: product.product_id,
          total_quantity: product.total_quantity
        }
      end
    end
    render json: results
  end

  def top_revenue_products

    results = Product.joins(sale_products: :sale)
    .select("products.id, products.name, categories.name AS category_name, SUM(sale_products.quantity * products.price) AS total_revenue")
    .joins(categories_products: :category)
    .group("products.id, categories.name")
    .order("total_revenue DESC")
    .limit(3)
    .group_by(&:category_name)

    render json: results
  end


  def purchases_by_parameters
    result_sales = get_sales_by_parameters(params)

    render json: result_sales
  end


  def purchases_by_granularity
    granularity = params[:granularity]
    formats = {
      "hour" => "DATE_TRUNC('hour', sales.created_at)",
      "day" => "DATE_TRUNC('day', sales.created_at)",
      "week" => "DATE_TRUNC('week', sales.created_at)",
      "year" => "DATE_TRUNC('year', sales.created_at)"
    }

    formats_response = {
      "hour" => "%Y-%m-%d %H:00",
      "day" => "%Y-%m-%d",
      "week" => "%Y-%m-%d",
      "year" => "%Y"
    }

    render json: { error: "Invalid granularity" }, status: :unprocessable_entity if !formats.key?(granularity)

    result_sales = get_sales_by_parameters(params).group(formats[granularity]).count

    result_sales = result_sales.map do |period, total_sales|
      period_label = period.strftime(formats_response[granularity])
      {
        period_label => total_sales.to_i
      }
    end

    render json: result_sales.reduce(&:merge)
  end

  private

  
  def get_sales_by_parameters(params)
    result_sales = Sale.joins(:sale_products, :products)
    result_sales = result_sales.where(:created_at => params[:start_date].to_time..(params[:end_date].to_time)) if params[:start_date].present? && params[:end_date].present?
    result_sales = result_sales.joins(sale_products: { product: :categories }).where(categories: { id: params[:category_id] }) if params[:category_id].present?
    result_sales = result_sales.where(client_id: params[:client_id]) if params[:client_id].present?
    result_sales = result_sales.where(products: { user_id: params[:admin_id] }) if params[:admin_id].present?
    result_sales.distinct
    
  end

  def authenticate_admin!
    unless @current_user.is_a?(Administrator)
      render json: { error: "Only admin can use this" }, status: :unauthorized
    end
  end

  # faltarian los test
end
