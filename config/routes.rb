Awesomefoundation::Application.routes.draw do
  constraints(SubdomainConstraint) do
    match "/apply" => "subdomains#apply"
    match "*url"   => "subdomains#chapter"
    match "/"      => "subdomains#chapter"
  end

  match "/blog/contact/" => redirect("/en/contact")
  match "/blog/about/"   => redirect("/en/about_us")
  match "/blog"          => redirect("http://blog.awesomefoundation.org")
  match "/blog/*path"    => redirect { |params, request| "http://blog.awesomefoundation.org/#{params[:path]}" }, :format => false
  match "/apply"         => redirect("/en/submissions/new")

  resources :passwords, :controller => 'clearance/passwords', :only => [:new, :create]

  resources :users, :shallow => true do
    resource :password, :controller => 'clearance/passwords', :only => [:create, :edit, :update]
  end

  scope "(:locale)", :locale => /en|es|fr|pt|ru/ do
    resource  :session, controller: :sessions, only: [:new, :create, :destroy]

    match "sign_in",  :to => "sessions#new"
    match "sign_out", :to => "sessions#destroy", :via => :delete

    resources :users, :only => [:index, :update, :edit] do
      resource :admins, :only => [:create, :destroy]
    end

    resources :chapters, :only => [:index, :show, :new, :create, :edit, :update] do
      resources :finalists, :only => [:index]
      resources :projects,  :only => [:index, :show]
      resources :users,     :only => [:index]
    end

    resources :invitations, :only => [:new, :create] do
      resources :acceptances, :only => [:new, :create]
    end

    resources :funded_projects, :path => "projects", :only => [:index]

    resources :projects, :except => [:index] do
      member do
        put "hide"
        put "unhide"
      end
      resource :winner, :only => [:create, :destroy]
      resource :vote, :only => [:create, :destroy]
    end

    resources :submissions, :controller => "projects"

    resources :roles, :only => [:destroy] do
      resource :promotions, :only => [:create, :destroy]
    end

    %w(about_us faq).each do |page|
      match page, :to => 'high_voltage/pages#show', :id => page
    end

    root :to => 'home#index'
  end

  match "/404", :to => "errors#not_found"

  # With the catchall route, explicitly mount Evergreen
  if Rails.env.development? || Rails.env.test?
    mount Evergreen::Application, :at => '/evergreen'
  end

  # All other routes are considered 404s. ActionController::RoutingError
  # will catch them, but that fills our logs with noisy exceptions.
  match '*url', :to => 'errors#not_found', :via => [:get]
end
