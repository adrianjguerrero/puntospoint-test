require 'csv'

class DailyPurchaseReportJob
  include Sidekiq::Job
  def perform
    puts "Daily Purchase Report Job started"
    sales = Sale.where(created_at: 1.day.ago.beginning_of_day..1.day.ago.end_of_day).includes(:sale_products, :client, :products)
    return if sales.empty?

    csv_data = generate_csv(sales)

    send_report(csv_data)
  end
  
  private

  def generate_csv(sales)
    generated_csv = CSV.generate(headers: true) do |csv|
      csv << ['ID de Venta', 'Cantidad Total', 'Monto Total', 'Productos', 'Cliente', 'Fecha de Creación']
  
      sales.each do |sale|
        sale_products = SaleProduct.where(sale_id: sale.id)
        total_quantity = sale_products.sum(:quantity)
        total_amount = sale.total
        products = sale_products.map { |sp| sp.product.name }.join(", ")
        client_name = sale.client.name
        created_at = sale.created_at.strftime("%d/%m/%Y %H:%M")
      
        csv << [sale.id, total_quantity, total_amount, products, client_name, sale.created_at.strftime("%d/%m/%Y %H:%M")]
      end
    end
    # File.write(Rails.root.join('tmp', 'daily_purchase_report.csv'), generated_csv)

    generated_csv

  end

  def send_report(csv_data)
    AdminMailer.send_report(csv_data, Administrator.all).deliver_now 
  end
end
