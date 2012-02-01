class ChaptersController < ApplicationController
  before_filter :must_be_admin, :only => [:new, :create]

  def index
    @chapters = Chapter.all
  end

  def new
    @chapter = Chapter.new
  end

  def create
    chapter = Chapter.new(params[:chapter])
    if chapter.save
      redirect_to chapters_path
    else
      render :new
    end
  end

  def show
    @chapter = Chapter.find(params[:id])
  end
end
