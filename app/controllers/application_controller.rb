class ApplicationController < ActionController::Base
  include Clearance::Authentication
  protect_from_forgery

  def must_be_logged_in
    unless current_user.present?
      flash[:notice] = "You must be logged in."
      redirect_to root_url
    end
  end

  def must_be_admin
    unless current_user.try(:admin?)
      flash[:notice] = "You must be an administrator."
      redirect_to root_url
    end
  end
end
