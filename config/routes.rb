Rails.application.routes.draw do
  devise_for :users
  # You can have the root of your site routed with "root"
  resources :bets, except: [:new, :edit]
  resources :weeks, except: [:new, :create] do
    member do
      get :request_bets
    end
  end
  resources :transactions, only: [:new, :index, :create]
  resources :users, except: [:delete, :destroy]
  get 'payments', to: 'payments#index', as: 'payments'

  root 'weeks#index'
end
