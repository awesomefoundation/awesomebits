class HomeController < ApplicationController
  def index
    @chapters = Chapter.active.visitable.for_display
    @projects = Project.recent_winners.preload(:primary_photo, :chapter).limit(15)
  end
end
