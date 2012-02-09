class ProjectMailer < ActionMailer::Base
  default :from => DO_NOT_REPLY

  def new_application(project)
    @project = project
    mail(:to => project.email,
         :subject => "[Awesome] Thanks for applying!")
  end

  def winner(project)
    @project = project
    mail(:to => project.email,
         :subject => "[Awesome] Your project won!")
  end
end
