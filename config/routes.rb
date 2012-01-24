Awesomefoundation::Application.routes.draw do
  resource :sessions, :to => 'Clearance::Sessions'

  match '/chapters/show', :to => 'pages#chapters'
  resources :users
  resources :chapters do
    resources :invitations
  end
  resources :projects

  root :to => 'home#index'
end
