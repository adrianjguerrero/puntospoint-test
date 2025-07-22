class StadisticsController < ApplicationController
  before_action :authorize
  before_action :authenticate_admin!

  def most_purchased_products_by_category
    cache_key = "most_purchased_products_by_category"
    results = $redis.get(cache_key)
    results = nil if Rails.env.test?
  
    return render json: JSON.parse(results) if results
      
  
    results = Category
      .select("categories.name AS category_name, products.id AS product_id, products.sales_count AS total_quantity")
      .joins(:products)
      .where("products.sales_count > 0")
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

    $redis.set(cache_key, results.to_json, ex: 1.hour.to_i) if Rails.env != 'test'
    render json: results
  end

  def top_revenue_products
    cache_key = "top_revenue_products"
    results = $redis.get(cache_key)
    results = nil if Rails.env.test?
  
    return render json: JSON.parse(results) if results

    results = Product.joins(sale_products: :sale)
    .select("products.id, products.name, categories.name AS category_name, SUM(sale_products.quantity * products.price) AS total_revenue")
    .joins(categories_products: :category)
    .group("products.id, categories.name")
    .order("total_revenue DESC")
    .limit(3)
    .group_by(&:category_name)

    results = results.transform_values do |products|
      products.map do |product|
        {
          product_id: product.id,
          product_name: product.name,
          total_revenue: product.total_revenue
        }
      end
    end

    $redis.set(cache_key, results.to_json, ex: 1.hour.to_i) if Rails.env != 'test'
    render json: results
  end


  def purchases_by_parameters

    key_cache = key_cache_constructor(params)
    results = $redis.get(key_cache)
    results = nil if Rails.env.test?
    
    return render json: JSON.parse(results) if results

    if good_time_format? == false
      return render json: { error: "Invalid date format" }, status: :unprocessable_entity
    end

    result_sales = get_sales_by_parameters(params)

    $redis.set(key_cache, result_sales.to_json, ex: 1.hour.to_i) if Rails.env != 'test'

    render json: result_sales
  end


  def purchases_by_granularity

    key_cache = key_cache_constructor(params)
    results = $redis.get(key_cache)
    
    results = nil if Rails.env.test?
    return render json: JSON.parse(results) if results


    if good_time_format? == false
      return render json: { error: "Invalid date format" }, status: :unprocessable_entity
    end

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

    $redis.set(key_cache_constructor(params), result_sales.to_json, ex: 1.hour.to_i) if Rails.env != 'test'
    render json: result_sales.reduce(&:merge)
  end

  private

  def key_cache_constructor(params)
    key_cache = ''
    key_cache += "start_date=#{params[:start_date]}::" if params[:start_date].present?
    key_cache += "end_date=#{params[:end_date]}::" if params[:end_date].present?
    key_cache += "category_id=#{params[:category_id]}::" if params[:category_id].present?
    key_cache += "client_id=#{params[:client_id]}::" if params[:client_id].present?
    key_cache += "admin_id=#{params[:admin_id]}::" if params[:admin_id].present?
    key_cache += "granularity=#{params[:granularity]}::" if params[:granularity].present?
    key_cache
  end


  def get_sales_by_parameters(params)
    result_sales = Sale.joins(:sale_products, :products)
    if params[:start_date].present? && params[:end_date].present?
      result_sales = result_sales.where(:created_at => params[:start_date].to_time..(params[:end_date].to_time))
    else
      time_to_use = params[:start_date]&.to_time || params[:end_date]&.to_time
      result_sales = result_sales.where(:created_at => time_to_use) if !time_to_use.nil?
    end
    result_sales = result_sales.joins(sale_products: { product: :categories }).where(categories: { id: params[:category_id] }) if params[:category_id].present?
    result_sales = result_sales.where(client_id: params[:client_id]) if params[:client_id].present?
    result_sales = result_sales.where(products: { user_id: params[:admin_id] }) if params[:admin_id].present?
    result_sales.distinct
    
  end

  def good_time_format?
    correct_time = true
    correct_time = time_is_correctly_formatted?(params[:start_date]) if params[:start_date].present?
    correct_time = time_is_correctly_formatted?(params[:end_date]) if params[:end_date].present? && correct_time != false
    correct_time
  end

  def time_is_correctly_formatted?(time_string)
    return true if time_string.blank?
    return false if time_string.is_a?(String) == false
    begin
      time_string.to_time
      true
    rescue ArgumentError
      false
    rescue NoMethodError
      false
    end
  end


end
