class SubdomainsController < ApplicationController
  before_action :find_chapter

  def chapter
    if @chapter
      redirect_to(chapter_url(@chapter.slug, :subdomain => @subdomain)) and return

    else
      redirect_to(root_url(:subdomain => @subdomain)) and return
    end
  end

  def apply
    redirect_to(new_submission_url(:subdomain => @subdomain, :chapter => @chapter)) and return
  end

  protected

  def find_chapter
    subdomains = request.subdomains
    subdomain  = subdomains.shift

    begin
      @chapter = Chapter.find(subdomain)
      I18n.locale = @chapter.locale

    rescue ActiveRecord::RecordNotFound
      @chapter = nil
    end

    @subdomain = subdomains.unshift("www").join(".")
  end
end
