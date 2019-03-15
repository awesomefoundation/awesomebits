class ErrorsController < ApplicationController
  def not_found
    render_404
  end

  def internal_server_error
    render status: :internal_server_error, file: File.join(Rails.root, "public", "500.html"), content_type: :html
  end
end
