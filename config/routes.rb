Rails.application.routes.draw do
  root "users#index"

  resources :users

  delete "logout", to: "sessions#destroy", as: :logout
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"

  get "scan", to: "scans#show"
  post "scan", to: "scans#show"

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
