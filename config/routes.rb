Rails.application.routes.draw do
  resources :bets

  resources :weeks

  devise_for :users
  # You can have the root of your site routed with "root"
  root 'home#index'
end
