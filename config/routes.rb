Rails.application.routes.draw do
  get  "login",  to: "sessions#new",     as: :login
  post "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get  "signup", to: "registrations#new",    as: :signup
  post "signup", to: "registrations#create"

  resources :passwords, param: :token, only: %i[ new create edit update ]

  resources :tasks, only: %i[ create update destroy ] do
    member do
      post :complete
      post :uncomplete
      post :skip
      post :defer
    end
  end

  get "quests",    to: "quests#index",      as: :quests
  get "routines",  to: "routines#index",    as: :routines
  get "sanctuary", to: "sanctuaries#show",  as: :sanctuary

  post "sanctuary/purchase/:key", to: "decorations#purchase", as: :purchase_decoration
  post "sanctuary/equip/:key",    to: "decorations#equip",    as: :equip_decoration
  post "sanctuary/unequip/:slot", to: "decorations#unequip",  as: :unequip_decoration

  get "dashboard", to: "dashboard#show", as: :dashboard
  get "settings",  to: "settings#show",  as: :settings

  namespace :admin do
    root to: redirect("/admin/users")
    get "design-system", to: "design_system#show", as: :design_system
    resources :users, only: %i[ index show ]
  end

  get   "profile",          to: "profiles#details",          as: :profile
  get   "profile/password", to: "profiles#password",         as: :profile_password
  patch "profile/email",    to: "profiles#update_email"
  patch "profile/password", to: "profiles#update_password"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
end
