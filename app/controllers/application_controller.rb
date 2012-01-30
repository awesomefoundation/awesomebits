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
    redirect_to root_url unless current_user.try(:admin?)
  end

  def current_chapter
    Chapter.find(params[:chapter_id])
  end
end
