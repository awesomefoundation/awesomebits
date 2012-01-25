class ApplicationController < ActionController::Base
  include Clearance::Authentication
  protect_from_forgery

  def must_be_logged_in
    redirect_to root_url unless current_user.present?
  end

  def must_be_admin
    redirect_to root_url unless current_user.try(:admin?)
  end
end
