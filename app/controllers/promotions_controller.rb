class PromotionsController < ApplicationController
  before_action { |c| c.must_be_able_to_manage_chapter_users(params[:role_id]) }

  def create
    role = Role.find(params[:role_id])
    role.name = 'dean'
    if role.save
      render :json => { :role => role.name, :role_id => role.id }
    else
      render :json => { :message => I18n.t("users.user.error_dean_promotion") }, :status => 400
    end
  end

  def destroy
    role = Role.find(params[:role_id])
    role.name = 'trustee'
    if role.save
      render :json => { :role => role.name, :role_id => role.id }
    else
      render :json => { :message => I18n.t("users.user.error_dean_demotion") }, :status => 400
    end
  end

end
