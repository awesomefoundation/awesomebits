Awesomefoundation::Application.routes.draw do
  scope "(:locale)", :locale => /en/ do
    resources :sessions

    match "sign_in", :to => "sessions#new"
    match "sign_out", :to => "sessions#destroy", :via => :delete

    resources :users do
      resource :admins, :only => [:create, :destroy]
    end

    resources :chapters do
      resources :finalists, :only => [:index]
      resources :projects,  :only => [:index]
      resources :users,     :only => [:index]
    end

    resources :invitations, :only => [:new, :create] do
      resources :acceptances, :only => [:new, :create]
    end

    resources :projects do
      resource :winner, :only => [:create, :destroy]
      resource :vote, :only => [:create, :destroy]
    end

    resources :submissions, :controller => "projects"

    resources :roles do
      resource :promotions, :only => [:create, :destroy]
    end

    resources :pages

    root :to => 'home#index'
  end
end
