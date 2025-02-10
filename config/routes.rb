Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      namespace :admin do
        resources :home, only: [:index]
        resources :events, only: %i[index show create update destroy]
        resources :users, only: %i[index show create update destroy]
        resources :roles
        resources :permissions
        get 'dashboard', to: 'dashboard#stats'
      end

      namespace :organizer do
        resources :events, only: %i[index show create update destroy]
        get 'dashboard', to: 'dashboard#stats'
      end

      namespace :public do
        resources :events, only: %i[index show]
        get 'home', to: 'home#index'
      end
    end
  end
end
