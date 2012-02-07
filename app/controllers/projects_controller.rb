class ProjectsController < ApplicationController
  before_filter :must_be_logged_in, :except => [:new, :create]

  include ApplicationHelper

  def index
    @start_date, @end_date = extract_timeframe
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
end
