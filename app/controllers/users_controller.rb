class UsersController < ApplicationController
  before_filter :ensure_chapter, :only => [:index]
  before_filter :ensure_current_user_or_admin, :only => [:update, :edit]
  before_filter :must_be_logged_in

  def index
    @chapter = Chapter.find(params[:chapter_id])
    @users = @chapter.users.order(:id)
  end

  def update
    @user = User.find(params[:id])
    unless params[:user][:password].blank?
      @user.password = params[:user][:password]
    end
    if @user.update_attributes(params[:user])
      redirect_to chapter_projects_path(@user.last_viewed_chapter_id)
    else
      render :edit
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  private

  def ensure_current_user_or_admin
    unless current_user.can_edit_profile?(params[:id])
      flash[:notice] = "You do not have permission to modify this account."
      redirect_to root_path
    end
  end

  def ensure_chapter
    if params[:chapter_id].blank?
      if current_user.last_viewed_chapter_id
        redirect_to chapter_users_path(current_user.last_viewed_chapter_id)
      elsif current_user.admin?
        redirect_to chapter_users_path(Chapter.first)
      else
        redirect_to chapter_users_path(current_user.chapters.first)
      end
    end
  end

end
