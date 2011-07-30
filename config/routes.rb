# encoding: utf-8
Dis::Application.routes.draw do
  # Авторизация редактора
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure',            to: 'sessions#failure'
  resource :session, only: :destroy
  
  # Работа с пользователями
  resources :users, only: [:index, :create, :update, :destroy] do
    collection do
      get :start
    end
    member do
      get  :auth
      post :request_auth
    end
  end
  
  # Вики-страницы
  match '/all.json', to: 'contents#all'
  
  root              via: :get,  to: 'contents#show',    defaults: { path: '' }
  root              via: :put,  to: 'contents#update',  defaults: { path: '' }
  match '/edit',                to: 'contents#edit',    defaults: { path: '' }
  match '/restore', via: :post, to: 'contents#restore', defaults: { path: '' }
  
  match '/*path/edit',                    to: 'contents#edit'
  match '/*path/restore',   via: :post,   to: 'contents#restore'
  match '/*path',           via: :get,    to: 'contents#show'
  match '/*path',           via: :put,    to: 'contents#update'
  match '/*path',           via: :delete, to: 'contents#destroy'
end
