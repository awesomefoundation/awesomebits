class HomeController < ApplicationController
  def index
    @chapters = Chapter.visitable.alphabetically.all
    @projects = fill_out(Project.recent_winners.limit(10).all, 15){ Project.new }
  end

  private

  def fill_out(array, up_to, &fill_with)
    (array + (1..up_to).map(&fill_with)).first(up_to)
  end
end
