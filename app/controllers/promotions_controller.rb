class PromotionsController < ApplicationController
  before_filter :must_be_admin

  def create
    role = Role.find(params[:role_id])
    role.name = 'dean'
    role.save
    redirect_to chapter_users_path(role.chapter)
  end

  def destroy
    role = Role.find(params[:role_id])
    role.name = 'trustee'
    role.save
    redirect_to chapter_users_path(role.chapter)
  end

end
