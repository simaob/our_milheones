Rails.application.routes.draw do
  devise_for :users
  # You can have the root of your site routed with "root"
  resources :bets
  resources :weeks, except: [:new, :create]
  resources :payments, except: [:edit, :update]

  root 'weeks#index'
end
