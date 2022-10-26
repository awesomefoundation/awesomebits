Rails.application.routes.draw do
  if ENV["AWS_BUCKET"].present?
    mount Shrine.uppy_s3_multipart(:cache) => '/s3/multipart'
  else
    mount Tus::Server => '/uploads'
  end

  constraints(SubdomainConstraint) do
    get "/apply" => "subdomains#apply"
    get "*url"   => "subdomains#chapter"
    get "/"      => "subdomains#chapter"
  end

  get "/blog/contact/" => redirect("/en/contact")
  get "/blog/about/"   => redirect("/en/about_us")
  get "/blog"          => redirect("http://blog.awesomefoundation.org")
  get "/blog/*path"    => redirect { |params, request| "http://blog.awesomefoundation.org/#{Addressable::URI.escape(params[:path])}" }, :format => false
  get "/apply"         => redirect("/en/submissions/new")

  resources :passwords, :controller => 'clearance/passwords', :only => [:new, :create]

  resources :users, :shallow => true do
    resource :password, :controller => 'clearance/passwords', :only => [:create, :edit, :update]
  end

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    resource  :session, controller: :sessions, only: [:new, :create, :destroy]

    get "sign_in",  :to => "sessions#new"
    delete "sign_out", :to => "sessions#destroy"

    resources :users, :only => [:index, :update, :edit] do
      resource :admins, :only => [:create, :destroy]
    end

    resources :chapters, :only => [:index, :show, :new, :create, :edit, :update] do
      resources :finalists, :only => [:index]
      resources :projects,  :only => [:index, :show] do
        resource :winner, :only => [:edit]
      end
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
      resources :comments
      resource :winner, :only => [:create, :update, :destroy]
      resource :vote, :only => [:create, :destroy]
    end

    resources :submissions, controller: "projects" do
      collection do
        get "success"
      end
    end

    resources :roles, :only => [:destroy] do
      resource :promotions, :only => [:create, :destroy]
    end

    %w(about_us faq start_a_chapter).each do |page|
      get page, :to => 'high_voltage/pages#show', :id => page
    end

    root :to => 'home#index'
  end

  get "/404", :to => "errors#not_found"
  get "/500", :to => "errors#internal_server_error"

  # All other routes are considered 404s. ActionController::RoutingError
  # will catch them, but that fills our logs with noisy exceptions.
  get '*url', :to => 'errors#not_found'
end
