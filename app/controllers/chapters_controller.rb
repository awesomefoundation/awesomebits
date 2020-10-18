class ChaptersController < ApplicationController
  before_action :ensure_lowercase_id, :only => [:show, :edit]
  before_action :must_be_admin, :only => [:new, :create]
  before_action :must_be_able_to_manage_chapter, :only => [:edit, :update]

  # Display all chapters (including inactive ones) to ensure that
  # everything gets crawled for SEO purposes. This can be rethought
  # in the future if needed.
  def index
    @chapters = chapter_source.visitable.sort_by(&CountrySortCriteria.new(COUNTRY_PRIORITY))
  end

  def show
    @chapter = Chapter.find(params[:id])
  end

  def new
    @chapter = Chapter.new
  end

  def create
    @chapter = Chapter.new(chapter_params)
    if @chapter.save
      redirect_to(@chapter)
    else
      render :new
    end
  end

  def edit
    @chapter = Chapter.find(params[:id])
  end

  def update
    @chapter = Chapter.find(params[:id])
    if @chapter.update_attributes(chapter_params)
      redirect_to(@chapter)
    else
      render :edit
    end
  end

  protected

  def chapter_params
    params.require(:chapter).permit(:name, :twitter_url, :facebook_url, :instagram_url, :blog_url, :rss_feed_url, :description, :country, :extra_question_1, :extra_question_2, :extra_question_3, :slug, :email_address, :time_zone, :inactive, :locale, :submission_response_email, :hide_trustees, :application_intro)
  end

  def ensure_lowercase_id
    if params[:id].match(/[A-Z]+/)
      redirect_to(:id => params[:id].parameterize, :status => :moved_permanently) && return
    end
  end

  def chapter_source
    if params[:include_inactive]
      Chapter
    else
      Chapter.active
    end
  end
end
