class RolesController < ApplicationController
  before_filter :must_be_admin

  def destroy
    role = Role.find(params[:id])
    if role.destroy
      render :json => { :role_id => role.id }
    else
      render :json => { :message => I18n.t("users.user.error_removing_user") }, :status => 400
    end
  end

end
