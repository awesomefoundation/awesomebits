class ApplicationController < ActionController::Base
  include Clearance::Authentication
  protect_from_forgery
  before_filter :set_locale

  def must_be_logged_in
    unless current_user.present?
      flash[:notice] = t("flash.permissions.must-be-logged-in")
      redirect_to root_url
    end
  end

  def must_be_admin
    unless current_user.try(:admin?)
      flash[:notice] = t("flash.permissions.must-be-admin")
      redirect_to root_url
    end
  end

  def must_be_able_to_manage_chapter
    chapter = Chapter.find(params[:id])
    unless current_user.try(:admin?) || (current_user && current_user.can_manage_chapter?(chapter))
      flash[:notice] = t("flash.permissions.must-be-dean-or-admin")
      redirect_to root_url
    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end

end
