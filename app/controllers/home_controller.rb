class HomeController < ApplicationController
  def index
    @chapters = Chapter.visitable.alphabetically.all
    @projects = Project.recent_winners.limit(10).all
  end
end
