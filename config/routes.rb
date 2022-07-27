require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  
  root 'invoices#home'
  devise_for :users

  resources :invoices, only: [:index] do
    collection do
      get 'import'
      post 'upload'
    end
  end

end
