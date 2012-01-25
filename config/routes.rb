Awesomefoundation::Application.routes.draw do
  resource :sessions, :to => 'Clearance::Sessions'

  match '/chapters/show', :to => 'pages#chapters'
  resources :users
  resources :chapters do
    resources :invitations
  end
  resources :invitations, :only => [:new, :create] do
    resources :acceptances, :only => [:new, :create]
  end
  resources :projects

  match "sign_in", :to => "Clearance::Sessions#new"
  match "sign_out", :to => "Clearance::Sessions#destroy", :via => :delete
  root :to => 'home#index'
end
