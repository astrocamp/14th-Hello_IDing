Rails.application.routes.draw do
  root to: 'home#index'

  resources :home
  
  devise_for :users, controllers: { 
                                    sessions: 'users/sessions', 
                                    registrations: 'users/registrations',
                                    omniauth_callbacks: "users/omniauth_callbacks"
                                  }
  
  namespace :admin do
    resources :restaurants do
      resources :tables
      resources :open_times, shallow: true, only: [:index, :create, :edit, :update, :destroy]
    end
  end

  resources :tables

  resources :restaurants do
    resources :reservations
  end


  get "/testcss" ,to: 'home#show'
  
  
  resources :restaurants, only: [:show]


end
