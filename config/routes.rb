Rails.application.routes.draw do
  devise_for :users, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    registration: "signup"
  },
  controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?


  # Ruta protegida para crear una venta
  authenticate :user do
    post "sales", to: "sale#create"
    get "most_sold_products", to: "stadistics#most_purchased_products_by_category"
    get "top_revenue_products", to: "stadistics#top_revenue_products"
    get "purchases_by_parameters", to: "stadistics#purchases_by_parameters"
    get "purchases_by_granularity", to: "stadistics#purchases_by_granularity"
  end

end
