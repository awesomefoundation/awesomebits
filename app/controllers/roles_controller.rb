class RolesController < ApplicationController
  before_filter :must_be_admin

  def destroy
    role = Role.find(params[:id])
    role.destroy
    render :json => { :role_id => role.id }
  end

end
