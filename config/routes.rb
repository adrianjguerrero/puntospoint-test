Rails.application.routes.draw do

  post "register", to: "users/sessions#create"
  post "login", to: "users/sessions#login"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?



  post "sales", to: "sale#create"
  get "most_sold_products", to: "stadistics#most_purchased_products_by_category"
  get "top_revenue_products", to: "stadistics#top_revenue_products"
  get "purchases_by_parameters", to: "stadistics#purchases_by_parameters"
  get "purchases_by_granularity", to: "stadistics#purchases_by_granularity"

end
