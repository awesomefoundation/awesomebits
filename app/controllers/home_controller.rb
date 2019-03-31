class HomeController < ApplicationController
  def index
    @chapters = Chapter.active.visitable.for_display
    @projects = Project.recent_winners.limit(15)
  end
end
