class ProjectMailer < ActionMailer::Base
  default :from => FROM_ADDRESS

  def new_application(project)
    @project = project
    mail(:to => project.email,
         :subject => "[Awesome] Thanks for applying!")
  end
end
