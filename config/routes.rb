Awesomefoundation::Application.routes.draw do

  resources :sessions

  match "sign_in", :to => "sessions#new"
  match "sign_out", :to => "sessions#destroy", :via => :delete

  resources :users

  resources :chapters do
    resources :finalists, :only => [:index]
    resources :projects, :only => [:index]
    resources :users, :only => [:index]
  end

  resources :invitations, :only => [:new, :create] do
    resources :acceptances, :only => [:new, :create]
  end

  resources :projects do
    resource :winner, :only => [:create, :destroy]
    resources :votes, :only => [:create]
  end

  resources :votes, :only => [:destroy]

  resources :submissions, :controller => "projects"

  resources :roles do
    resource :promotions, :only => [:create, :destroy]
  end

  root :to => 'home#index'
end
