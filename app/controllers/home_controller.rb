class HomeController < ApplicationController
  def index
    @chapters = Chapter.visitable.for_display.all
    @projects = Project.recent_winners.limit(15).all
  end
end
