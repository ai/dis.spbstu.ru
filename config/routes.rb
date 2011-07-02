Dis::Application.routes.draw do
  resource :session, only: :destroy
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: 'sessions#failure'
  
  resources :users
  
  root to: 'contents#show'
end
