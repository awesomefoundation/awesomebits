class PromotionsController < ApplicationController
  before_filter :must_be_admin

  def create
    role = Role.find(params[:role_id])
    role.name = 'dean'
    if role.save
      render :json => { :role => role.name, :role_id => role.id }
    else
      render :json => { :message => I18n.t("users.user.error-dean-promotion") }, :status => 400
    end
  end

  def destroy
    role = Role.find(params[:role_id])
    role.name = 'trustee'
    if role.save
      render :json => { :role => role.name, :role_id => role.id }
    else
      render :json => { :message => I18n.t("users.user.error-dean-demotion") }, :status => 400
    end
  end

end
