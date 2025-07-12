Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    sessions: 'overrides/sessions'
  }
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
        resources :events
        resources :users
        resources :roles
        resources :permissions
        resources :categories
        get 'dashboard', to: 'dashboard#stats'
      end

      namespace :organizer do
        resources :events
        get 'dashboard', to: 'dashboard#stats'
      end

      namespace :user do
      end

      namespace :public do
      end
    end
  end
end
