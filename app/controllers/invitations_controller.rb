class InvitationsController < ApplicationController
  before_filter :must_be_logged_in
  before_filter :must_be_able_to_invite

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = find_invitation(params[:invitation])
    @invitation.inviter = current_user
    if @invitation.save
      @invitation.send_invitation
      redirect_to projects_path
    else
      render :new
    end
  end

  private

  def find_invitation(attributes)
    invitation = Invitation.where(:email => attributes[:email]).
                            where(:chapter_id => attributes[:chapter_id]).
                            where("invitee_id IS NULL").
                            first
    invitation ||= Invitation.new
    invitation.attributes = attributes
    invitation
  end

  def must_be_able_to_invite
    unless current_user.can_invite?
      flash[:notice] = t("flash.permissions.cannot-invite")
      redirect_to root_path
    end
  end
end
