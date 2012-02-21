class AdminsController < ApplicationController
  before_filter :must_be_admin

  def create
    user = User.find(params[:user_id])
    user.admin = true
    user.save
    if user.save
      render :json => { :admin => true, :user_id => user.id }
    else
      render :json => { :message => "Admin promotion failed" }, :status => 400
    end
  end

  def destroy
    user = User.find(params[:user_id])
    user.admin = false
    user.save
    if user.save
      render :json => { :admin => false, :user_id => user.id }
    else
      render :json => { :message => "Admin demotion failed" }, :status => 400
    end
  end
end
