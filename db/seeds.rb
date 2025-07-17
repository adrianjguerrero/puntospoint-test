# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

Product.destroy_all
Sale.destroy_all
SaleProduct.destroy_all
Category.destroy_all
User.destroy_all
Image.destroy_all
CategoriesProduct.destroy_all

clients = Client.create([
  { name: 'Juan Pérez', email: 'juan@example.com', password_digest: 'password'},
  { name: 'María Gómez', email: 'maria@example.com', password_digest: 'password' }
])

administrator = Administrator.create([
  { name: 'Carlos López', email: 'carlos@puntospoint.com', password_digest: 'password'},
  { name: 'Adrian Guerrero', email: 'aguerrero@puntospoint.com', password_digest: 'password'}
])

categories = Category.create([
  { name: 'Electrónica' },
  { name: 'Ropa' },
  { name: 'Alimentos' },
  { name: 'Hogar' },
  { name: 'Juguetes' }
])

# Crear usuarios

# Crear productos
products = Product.create([
  { name: 'Smartphone', price: 300.00, stock: 50, user_id: Administrator.last.id, sales_count: 0 },
  { name: 'Camiseta', price: 20.00, stock: 100, user_id: Administrator.last.id, sales_count: 0 },
  { name: 'Laptop', price: 800.00, stock: 30, user_id: Administrator.last.id, sales_count: 0 },
  { name: 'Cereal', price: 5.00, stock: 200, user_id: Administrator.last.id, sales_count: 0 },
  { name: 'Sofá', price: 500.00, stock: 10, user_id: Administrator.last.id, sales_count: 0 },
  { name: 'Muñeca', price: 15.00, stock: 150, user_id: Administrator.last.id, sales_count: 0 }
])

# Crear imágenes
images = Image.create([
  { url: 'http://example.com/images/smartphone.jpg', imageable_type: 'Product', imageable_id: products[0].id },
  { url: 'http://example.com/images/camiseta.jpg', imageable_type: 'Product', imageable_id: products[1].id },
  { url: 'http://example.com/images/laptop.jpg', imageable_type: 'Product', imageable_id: products[2].id },
  { url: 'http://example.com/images/cereal.jpg', imageable_type: 'Product', imageable_id: products[3].id },
  { url: 'http://example.com/images/sofa.jpg', imageable_type: 'Product', imageable_id: products[4].id },
  { url: 'http://example.com/images/muneca.jpg', imageable_type: 'Product', imageable_id: products[5].id }
])

# Crear relaciones entre categorías y productos
CategoriesProduct.create([
  { product_id: products[0].id, category_id: categories[0].id },
  { product_id: products[1].id, category_id: categories[1].id },
  { product_id: products[2].id, category_id: categories[0].id },
  { product_id: products[3].id, category_id: categories[2].id },
  { product_id: products[4].id, category_id: categories[3].id },
  { product_id: products[5].id, category_id: categories[4].id }
])

# Crear ventas
sales = Sale.create([
  { total: 320.00, status: 'completed', client_id: clients[0].id, qty_products: 2, created_at: 1.day.ago },
  { total: 15.00, status: 'completed', client_id: clients[1].id, qty_products: 1, created_at: 1.day.ago },
  { total: 800.00, status: 'completed', client_id: clients[0].id, qty_products: 1, created_at: 1.day.ago },
])

# Crear productos de venta
SaleProduct.create([
  { sale_id: sales[0].id, product_id: products[0].id, quantity: 1, created_at: 1.day.ago },
  { sale_id: sales[0].id, product_id: products[1].id, quantity: 1, created_at: 1.day.ago },
  { sale_id: sales[1].id, product_id: products[5].id, quantity: 1, created_at: 1.day.ago },
  { sale_id: sales[2].id, product_id: products[2].id, quantity: 1, created_at: 1.day.ago },
])




