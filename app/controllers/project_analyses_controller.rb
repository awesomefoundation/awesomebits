class ProjectAnalysesController < ApplicationController
  before_action :require_login
  before_action :set_project

  def show_or_create
    # Delete existing analysis if force is true
    if params[:force].to_s == "true" && @project.project_analysis.present?
      @project.project_analysis.destroy
    end

    # Use cached analysis if it exists, otherwise generate a new one
    @project_analysis = @project.project_analysis || ProjectAnalysisGenerator.new(@project.id).call

    flash[:notice] = if @project_analysis.persisted?
      I18n.t("project_analyses.flash.cache_loaded")
    else
      I18n.t("project_analyses.flash.generated")
    end
    render :show
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
