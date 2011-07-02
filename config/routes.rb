Dis::Application.routes.draw do
  resource :session, only: :destroy
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure', to: 'sessions#failure'
  
  root to: 'contents#index'
end
