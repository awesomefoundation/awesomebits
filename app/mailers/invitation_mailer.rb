class InvitationMailer < ActionMailer::Base
  default from: "do_not_reply@awesomefoundation.org"

  def invite_trustee(invitation)
    @invitation = invitation
    mail(:to => invitation.email,
         :subject => "[Awesome] You've been invited to the #{invitation.chapter.name} chapter of the Awesome Foundation!")
  end

  def welcome_trustee(invitation)
    @invitation = invitation
    mail(:to => invitation.email,
         :subject => "[Awesome] Welcome to the #{invitation.chapter.name} chapter!")
  end
end
