class RolesController < ApplicationController
  before_filter :must_be_admin_or_dean_of_this_chapter

  def destroy
    role = Role.find(params[:id])
    role.destroy
    render :json => { :role_id => role.id }
  end

  private

  def must_be_admin_or_dean_of_this_chapter
    role = Role.find(params[:id])
    if !current_user.try(:admin?) && !current_user.can_remove_users?(role.chapter)
      flash[:notice] = t("flash.permissions.cannot-remove-user")
      redirect_to root_url
    end
  end
end
