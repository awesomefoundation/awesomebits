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
# 
  def timeframe
    if params[:filter]
      start_date = if params[:filter][:start].blank?
                     nil
                   else
                     Date.strptime(params[:filter][:start], "%Y-%m-%d")
                   end
      end_date = if params[:filter][:end].blank?
                     nil
                   else
                     Date.strptime(params[:filter][:end], "%Y-%m-%d")
                   end
      [start_date, end_date]
    else
      [nil, nil]
    end
  end
end
