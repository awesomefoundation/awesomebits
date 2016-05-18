class HomeController < ApplicationController
  def index
    @chapters = Chapter.active.visitable.for_display.all
    @projects = Project.recent_winners.limit(15).all
  end
end
