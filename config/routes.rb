Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: "dashboard#index"
  get 'people/:id', to: 'dashboard#person'
  get 'activity', to: 'dashboard#activity'

  resources :expenses, except: :index
  resources :payments, except: :index
  resources :friendships, only: [:new, :create, :destroy]
end
