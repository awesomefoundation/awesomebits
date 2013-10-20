class RolesController < ApplicationController
  before_filter { |c| c.must_be_able_to_manage_chapter_users(params[:id]) }

  def destroy
    role = Role.find(params[:id])
    role.destroy
    render json: { role_id: role.id }
  end
end
