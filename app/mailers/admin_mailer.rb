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
end
