class ChaptersController < ApplicationController
  before_filter :must_be_admin, :only => [:new, :create]
  before_filter :must_be_admin_or_dean_for_chapter, :only => [:edit, :update]
  def index
    @chapters = Chapter.all
  end

  def show
    @chapter = Chapter.find(params[:id])
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

  def edit
    @chapter = Chapter.find(params[:id])
  end

  def update
    @chapter = Chapter.find(params[:id])
    if @chapter.update_attributes(params[:chapter])
      redirect_to(@chapter)
    else
      render "edit"
    end
  end
end
