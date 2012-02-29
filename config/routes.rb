Awesomefoundation::Application.routes.draw do
  scope "(:locale)", :locale => /en/ do
    resources :sessions
    match "sign_in",  :to => "sessions#new"
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

    match "description", :to => "high_voltage/pages#show", :id => "description"
    match "about_us",    :to => "high_voltage/pages#show", :id => "about_us"
    match "contact",     :to => "high_voltage/pages#show", :id => "contact"
    match "faq",         :to => "high_voltage/pages#show", :id => "faq"
    match "trustees",    :to => "high_voltage/pages#show", :id => "trustees"

    root :to => 'home#index'
  end
end
