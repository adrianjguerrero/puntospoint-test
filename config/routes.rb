Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  post "register", to: "users/sessions#create"
  post "login", to: "users/sessions#login"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?



  post "sales", to: "sale#create"
  get "most_sold_products", to: "stadistics#most_purchased_products_by_category"
  get "top_revenue_products", to: "stadistics#top_revenue_products"
  get "purchases_by_parameters", to: "stadistics#purchases_by_parameters"
  get "purchases_by_granularity", to: "stadistics#purchases_by_granularity"

  post "products", to: "products#create"
  put "products/:id", to: "products#update"
  delete "products/:id", to: "products#destroy"
  get "products", to: "products#index"
  get "products/:id", to: "products#show"

end
