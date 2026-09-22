Rails.application.routes.draw do
  root "users#index"

  resources :users

  get "scan", to: "users#scan"
  post "scan", to: "users#initialize_from_qr"

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
