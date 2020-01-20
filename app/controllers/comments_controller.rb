class CommentsController < ApplicationController
  def create
    @project = Project.find(params[:project_id])
    @comment = @project.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
    else
      flash[:notice] = @comment.errors.full_messages.join(", ")
    end

    redirect_to [@project.chapter, @project]
  end

  private

  def comment_params
    params.require(:comment).permit(:viewable_by, :body)
  end
end
