class AdminMailer < ApplicationMailer
  default from: 'no-reply@puntospoint.com'

  def notify_first_sale(product, creator, other_admins)
    @product = product
    @creator = creator

    mail(
      to: creator.email,
      cc: other_admins.map(&:email),
      subject: "Primer venta del producto: #{@product.name}"
    )
  end

  def send_report(csv_data, admins)
    attachments["daily_purchase_report.csv"] = csv_data
    mail(to: admins.map(&:email), subject: "Informe Diario de Compras")
  end
end
