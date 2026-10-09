Rails.application.routes.draw do
  root "home#about"

  resources :users

  delete "logout", to: "sessions#destroy", as: :logout
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"

  get "scan", to: "scans#show"
  post "scan", to: "scans#show"
  get "opt_out", to: "scans#opt_out"

  get "highscores", to: "highscores#index"

  get "manual_input", to: "users#manual_edit"
  patch "manual_input", to: "users#manual_update", as: :manual_input_update

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
