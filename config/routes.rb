Awesomefoundation::Application.routes.draw do
  locale = I18n.default_locale.to_s
  match "/blog/contact/" => redirect("/#{locale}/contact")
  match "/blog/about/"   => redirect("/#{locale}/about_us")
  match "/blog"          => redirect("http://blog.awesomefoundation.org")
  match "/blog/*path"    => redirect { |params, request| "http://blog.awesomefoundation.org/#{params[:path]}" }, :format => false
  match "/apply"         => redirect("/#{locale}/submissions/new")

  scope "(:locale)", :locale => /he|en|pt|fr/ do
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

    resources :projects do
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
end
