Rails.application.routes.draw do
  devise_for :users
  # You can have the root of your site routed with "root"
  resources :bets, except: [:new, :edit]
  resources :weeks, except: [:new, :create]
  resources :transactions, only: [:new, :index, :create]
  resources :users, except: [:destroy]
  get 'payments', to: 'payments#index', as: 'payments'
  get 'metrics/all', to: 'metrics#all_time', as: 'all_time_metrics'
  get 'metrics(/:year)', to: 'metrics#show', as: 'metrics', constraints: { year: /\d{4}/ }

  root 'weeks#index'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Used by kamal-proxy to know when a new container is ready to receive traffic.
  get "up" => "rails/health#show", as: :rails_health_check
end
