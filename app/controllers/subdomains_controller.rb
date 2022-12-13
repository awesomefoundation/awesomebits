class SubdomainsController < ApplicationController
  before_action :find_chapter

  def chapter
    if @chapter
      redirect_to(chapter_url(@chapter.slug, url_parts))

    else
      redirect_to(root_url(url_parts))
    end
  end

  def apply
    redirect_to(new_submission_url({ chapter: @chapter }.merge(url_parts)))
  end

  def canonical
    redirect_to({ locale: nil }.merge(url_parts), status: :moved_permanently)
  end

  protected

  def url_parts
    if ENV['CANONICAL_HOST'].present?
      { host: ENV['CANONICAL_HOST'] }
    else
      { subdomain: @subdomain }
    end
  end

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
