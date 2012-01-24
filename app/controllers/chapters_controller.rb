class ChaptersController < ApplicationController
  def show
    @chapter = Chapter.find(params[:id])
  end
end
