class ProjectsController < ApplicationController
  before_filter :must_be_trustee, :except => [:new, :create]

  def index
    @projects = Project.visible_to(current_user)
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

  def which_month
  end
end
