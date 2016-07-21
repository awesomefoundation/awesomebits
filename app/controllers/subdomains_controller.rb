class SubdomainsController < ApplicationController
  before_filter :find_chapter

  def chapter
    if @chapter
      redirect_to(chapter_url(@chapter.slug, :subdomain => 'www')) and return

    else
      redirect_to(root_url(:subdomain => 'www')) and return
    end
  end

  def apply
    redirect_to(new_submission_url(:subdomain => 'www', :chapter => @chapter)) and return
  end

  protected

  def find_chapter
    @chapter = Chapter.find(request.subdomain)
    I18n.locale = @chapter.locale

  rescue ActiveRecord::RecordNotFound
    @chapter = nil
  end
end
