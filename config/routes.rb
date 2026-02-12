RailsChatbot::Engine.routes.draw do
  root to: 'chat#index'
  
  resources :conversations, only: [:index, :show, :create, :destroy] do
    resources :messages, only: [:create]
  end
  
  post 'messages', to: 'messages#create'
  get 'search', to: 'chat#search'
end
