class ProjectsController < ApplicationController
  before_filter :must_be_logged_in, :except => [:new, :create]

  def index
    @start_date, @end_date = timeframe
    @projects = Project.visible_to(current_user).during_timeframe(@start_date, @end_date)
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = "Thanks for applying!"
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @project = Project.find(params[:id])
  end

  private

  def timeframe
    start_date = params[:start].blank? ? nil : Date.strptime(params[:start], "%Y-%m-%d")
    end_date =   params[:end].blank?   ? nil : Date.strptime(params[:end],   "%Y-%m-%d")
    [start_date, end_date]
  end
end
