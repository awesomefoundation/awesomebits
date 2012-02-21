module UsersHelper

  def view_all_users?
    params[:chapter_id].blank?
  end

end
