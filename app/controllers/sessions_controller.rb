class SessionsController < Clearance::SessionsController
  def url_after_create
    submissions_path
  end
end
