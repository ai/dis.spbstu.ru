Dis::Application.routes.draw do
  resource :session, only: :destroy
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: 'sessions#failure'
  
  resources :users, only: [:index, :destroy, :update]
  
  root to: 'contents#show'
end
