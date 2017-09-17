class ApplicationController < ActionController::Base
  include Clearance::Authentication
  protect_from_forgery
  before_filter :set_locale
  before_filter :fix_chapter_ids

  def must_be_logged_in
    if current_user.blank? || !current_user.logged_in?
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

  def must_be_able_to_manage_chapter_users(role_id)
    role = Role.find(role_id)
    if !current_user.try(:admin?) && !current_user.can_manage_users?(role.chapter)
      flash[:notice] = t("flash.permissions.cannot-remove-user")
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

  def current_user
    super || Guest.new
  end

  def set_locale
    begin
      I18n.locale = params[:locale] || I18n.default_locale
    rescue I18n::InvalidLocale
      I18n.locale = I18n.default_locale
    end
  end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end

  def fix_chapter_ids
    if params[:chapter_id]
      chapter = Chapter.find_by_slug(params[:chapter_id])
      params[:chapter_id] = (chapter && chapter.id) || params[:chapter_id]
    end

    if params[:id]
      chapter = Chapter.find_by_id(params[:id])
      params[:id] = (chapter && chapter.id) || params[:id]
    end
  end

  def render_404
    respond_to do |format|
      format.html { render :status => 404, :template => "errors/not_found" }
      format.all { render :nothing => true, :status => 404 }
    end
  end
end
