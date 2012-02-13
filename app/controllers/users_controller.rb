class UsersController < ApplicationController
  before_filter :ensure_chapter, :only => [:index]
  before_filter :must_be_logged_in

  def index
    @chapter = Chapter.find(params[:chapter_id])
    @users = @chapter.users
  end

  private

  def ensure_chapter
    if params[:chapter_id].blank?
      if current_user.admin?
        redirect_to chapter_users_path(Chapter.first)
      else
        redirect_to chapter_users_path(current_user.chapters.first)
      end
    end
  end

end
