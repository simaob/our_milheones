Rails.application.routes.draw do
  devise_for :users
  # You can have the root of your site routed with "root"
  resources :bets
  resources :weeks, except: [:new, :create]
  resources :transactions, only: [:new, :index, :create]
  resources :users, except: [:delete, :destroy]

  root 'weeks#index'
end
