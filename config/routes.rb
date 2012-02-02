Awesomefoundation::Application.routes.draw do
  resources :sessions
  match "sign_in", :to => "sessions#new"
  match "sign_out", :to => "sessions#destroy", :via => :delete

  match '/chapters/show', :to => 'pages#chapters'
  match '/projects/show', :to => 'pages#projects'
  resources :users
  resources :chapters
  resources :invitations, :only => [:new, :create] do
    resources :acceptances, :only => [:new, :create]
  end
  resources :projects
  resources :submissions, :controller => "projects"

  root :to => 'home#index'
end
