class CommentsController < ApplicationController
  before_action :must_be_logged_in
  before_action :find_project

  def create
    @comment = @project.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      @comments = @project.comments.viewable_by(user: current_user, chapter: @project.chapter).by_date

      render json: { comments: @comments, project_id: @project.id }
    else
      render status: 400, json: { message: @comment.errors.full_messages.join(", ") }
    end
  end

  def destroy
    @comment = @project.comments.find(params[:id])

    unless current_user == @comment.user || current_user.can_edit_project?(@project)
      head :forbidden and return
    end

    if @comment.destroy
      head :ok
    else
      rener status: 400, json: { message: @comment.errors.full_messages.join(", ") }
    end
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def comment_params
    params.require(:comment).permit(:viewable_by, :body)
  end
end
