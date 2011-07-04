Dis::Application.routes.draw do
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: 'sessions#failure'
  resource :session, only: :destroy
  
  resources :users, only: [:index, :create, :update, :destroy] do
    collection do
      get :start
    end
    member do
      get  :auth
      post :request_auth
    end
  end
  
  root to: 'contents#show'
end
