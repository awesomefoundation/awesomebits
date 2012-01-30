class SessionsController < Clearance::SessionsController
  def url_after_create
    projects_path
  end
end
