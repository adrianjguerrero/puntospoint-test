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
  end

end
