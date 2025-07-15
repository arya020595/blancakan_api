Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :auth do
    post 'sign_in', to: 'auth#sign_in'
    post 'register', to: 'auth#register'
    post 'sign_out', to: 'auth#sign_out'
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :admin do
        resources :home, only: [:index]
        resources :events
        resources :users
        resources :roles
        resources :permissions
        resources :categories
        resources :event_types
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
