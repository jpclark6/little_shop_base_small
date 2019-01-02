Rails.application.routes.draw do
  root to: 'welcome#index'

  resources :items, only: [:index, :show]
  resources :merchants, only: [:index]

  get '/cart', to: 'cart#index'
  post '/cart/additem/:id', to: 'cart#add_item', as: 'cart_add_item'
  post '/cart/addmoreitem/:id', to: 'cart#add_more_item', as: 'cart_add_more_item'
  delete '/cart', to: 'cart#destroy', as: 'cart_empty'
  delete '/cart/item/:id', to: 'cart#remove_more_item', as: 'cart_remove_more_item'
  delete '/cart/item/:id/all', to: 'cart#remove_all_of_item', as: 'cart_remove_item_all'

  get '/login', to: 'session#new'
  post '/login', to: 'session#create'
  get '/logout', to: 'session#destroy'

  post '/coupon', to: 'coupon#create'

  get '/register', to: 'users#new', as: 'registration'
  resources :users, only: [:create, :update]

  get '/dashboard', to: 'merchants#show', as: 'dashboard'
  namespace :dashboard do
    resources :orders, only: [:show] do
      post '/items/:id/fulfill', to: 'orders#fulfill_item', as: 'item_fulfill'
    end
    resources :items, except: [:show]
    patch '/items/:id/enable', to: 'items#enable', as: 'enable_item'
    patch '/items/:id/disable', to: 'items#disable', as: 'disable_item'
  end
  get '/profile', to: 'profile#index', as: 'profile'

  get '/profile/edit', to: 'users#edit'
  namespace :profile do
    resources :orders, only: [:index, :create, :show, :destroy]
  end

  post '/admin/users/:merchant_id/items', to: 'dashboard/items#create', as: 'admin_user_items'
  patch '/admin/users/:merchant_id/items/:id', to: 'dashboard/items#update', as: 'admin_user_item'
  namespace :admin do
    resources :users, only: [:index, :show, :edit] do
      post '/enable', to: 'users#enable', as: 'enable'
      post '/disable', to: 'users#disable', as: 'disable'
      post '/upgrade', to: 'users#upgrade', as: 'upgrade'
      resources :orders, only: [:index, :show]
    end
    resources :merchants, only: [:show] do
      post '/enable', to: 'merchants#enable', as: 'enable'
      post '/disable', to: 'merchants#disable', as: 'disable'
      post '/upgrade', to: 'merchants#downgrade', as: 'downgrade'
      resources :items, only: [:index, :new, :edit]
    end
    resources :dashboard, only: [:index]
  end
end
