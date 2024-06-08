class UsersController < ApplicationController
  before_action :require_login
  before_action :ensure_chapter, :only => [:index]
  before_action :ensure_current_user_or_admin, :only => [:update, :edit]

  def index
    @users = User.all_with_chapter(params[:chapter_id])

    respond_to do |format|
      format.html do
        @users = @users.paginate(page: params[:page], per_page: 250)
      end
      format.csv do
        headers["Content-Disposition"] = "attachment; filename=#{current_chapter.slug}_users.csv" if current_chapter.present?
      end
    end
  end

  def update
    @user = User.find(params[:id])
    @user.set_password(params[:user].delete(:new_password))
    if @user.update(user_params)
      if params[:return_to].present?
        redirect_to params[:return_to]
      else
        redirect_to chapter_projects_path(current_user.last_viewed_chapter_id)
      end
    else
      render :edit
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :bio, :url)
  end

  def ensure_current_user_or_admin
    unless current_user.can_edit_profile?(params[:id])
      flash[:notice] = t("flash.permissions.cannot-modify-account")
      redirect_to root_path
    end
  end

  def ensure_chapter
    if params[:chapter_id].blank? && !current_user.admin?
      if current_user.last_viewed_chapter_id
        redirect_to chapter_users_path(current_user.last_viewed_chapter_id)
      else
        redirect_to chapter_users_path(current_user.chapters.first)
      end
    end
  end

  def current_chapter
    @chapter ||= Chapter.find_by_id(params[:chapter_id])
  end
  helper_method :current_chapter

end
