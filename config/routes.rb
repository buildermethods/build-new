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
      post :start
      post :defer
    end
  end

  get  "blitz", to: "blitz#show", as: :blitz
  post "blitz/:id/complete", to: "blitz#complete", as: :blitz_complete

  get "quests",    to: "quests#index",      as: :quests
  get "sanctuary", to: "sanctuaries#show",  as: :sanctuary

  post "sanctuary/purchase/:key", to: "decorations#purchase", as: :purchase_decoration
  post "sanctuary/equip/:key",    to: "decorations#equip",    as: :equip_decoration
  post "sanctuary/unequip/:slot", to: "decorations#unequip",  as: :unequip_decoration

  # First-run setup (/welcome/*) and "add more suggested chores"
  # (/add-chores/*) share one controller; `mode` picks the flow.
  get "welcome", to: "onboarding#intro", defaults: { mode: "setup" }, as: :welcome
  { "setup" => "welcome", "add" => "add-chores" }.each do |mode, base|
    defaults = { mode: mode }
    get  "#{base}/rooms",     to: "onboarding#rooms",          defaults: defaults, as: :"#{mode}_rooms"
    post "#{base}/rooms",     to: "onboarding#save_rooms",     defaults: defaults
    post "#{base}/preload",   to: "onboarding#preload",        defaults: defaults
    get  "#{base}/chores",    to: "onboarding#chores",         defaults: defaults, as: :"#{mode}_chores"
    post "#{base}/chores",    to: "onboarding#save_chores",    defaults: defaults
    get  "#{base}/frequency", to: "onboarding#frequency",      defaults: defaults, as: :"#{mode}_frequency"
    post "#{base}/frequency", to: "onboarding#save_frequency", defaults: defaults
  end
  get  "welcome/finish", to: "onboarding#finish",   defaults: { mode: "setup" }, as: :setup_finish
  post "welcome/finish", to: "onboarding#complete", defaults: { mode: "setup" }
  post "welcome/skip",   to: "onboarding#skip",     defaults: { mode: "setup" }, as: :skip_welcome

  resources :routines, only: %i[ index create update destroy ] do
    member { post :complete_all }
    resources :steps, only: [], controller: "routine_steps" do
      member do
        post :complete
        delete :uncomplete
      end
    end
  end

  resources :todos, only: %i[ index create update destroy ] do
    member do
      post :complete
      post :uncomplete
    end
  end

  resources :boss_battles, path: "battles", only: %i[ index show new create ] do
    member { post :abandon }
    resources :stages, only: [], controller: "boss_stages" do
      member do
        post :complete
        post :uncomplete
      end
    end
  end

  get "insights", to: "insights#index", as: :insights
  get "codex", to: "codex#index", as: :codex
  post "challenges/:period/claim", to: "challenges#claim", as: :claim_challenge
  get "achievements", to: "achievements#index", as: :achievements
  get "plan", to: "plans#show", as: :plan
  post "intentions", to: "intentions#create", as: :intentions
  delete "intentions", to: "intentions#destroy"

  get "dashboard", to: "dashboard#show", as: :dashboard
  get   "settings",       to: "settings#show",   as: :settings
  patch "settings",       to: "settings#update"
  post  "settings/reset", to: "settings#reset",  as: :reset_settings

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
