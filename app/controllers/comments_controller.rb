class CommentsController < ApplicationController
  def create
    @project = Project.find(params[:project_id])
    @comment = @project.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      @comments = @project.comments.viewable_by(user: current_user, chapter: @project.chapter).by_date

      render json: { comments: @comments, project_id: @project.id }
    else
      render status: 400, json: { message: @comment.errors.full_messages.join(", ") }
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:viewable_by, :body)
  end
end
