Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # Root path
  root "dashboard#index"

  # Main application routes
  resources :kegs do
    member do
      post :attach_to_tap
      post :end_keg
    end
    collection do
      get :available
    end
  end

  resources :taps do
    member do
      post :attach_keg
      post :detach_keg
    end
  end

  resources :drinks, only: [ :index, :show ] do
    member do
      patch :reassign
      post :cancel
    end
  end

  resources :pictures

  resources :sessions, only: [ :index, :show ], controller: :drinking_sessions

  resources :beverages do
    collection do
      get :search
    end
  end

  resources :beverage_producers

  resources :kegboard_configs do
    member do
      post :test_connection
    end
  end

  resources :users, only: [ :index, :show ] do
    member do
      get :stats
    end
  end

  # Admin routes
  namespace :admin do
    resources :kegs
    resources :taps
    resources :users
    resources :api_keys
    resources :authentication_tokens
    resource :site_settings, only: [ :show, :edit, :update ]
  end

  # API routes
  namespace :api do
    namespace :v1 do
      resources :kegs, only: [ :index, :show ] do
        member do
          post :tap
          post :end
        end
      end

      resources :drinks, only: [ :create, :index, :show ]

      resources :taps, only: [ :index, :show ] do
        member do
          get :temperature
        end
      end

      resources :sessions, only: [ :index, :show ], controller: :drinking_sessions

      resources :events, only: [ :index ]

      # Authentication
      post "auth/token", to: "auth#authenticate"
      post "auth/register", to: "auth#register"
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
