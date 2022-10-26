module ProjectsHelper
  def selectable_chapters_for(user)
    any_chapter = Chapter.where(:name => Chapter::ANY_CHAPTER_NAME).first
    if user.admin?
      [any_chapter] + Chapter.where.not(name: Chapter::ANY_CHAPTER_NAME).order(:name)
    else
      [any_chapter] + user.chapters.order(:name)
    end
  end

  def winnable_chapters_for(project)
    if current_user.admin?
      Chapter.visitable.for_display
    else
      project.in_any_chapter? ? current_user.dean_chapters : Array(project.chapter)
    end
  end

  def voting_chapters
    return @voting_chapters if @voting_chapters

    if current_user
      @voting_chapters = current_user.chapters

      if @voting_chapters.include?(@chapter)
        @voting_chapters = [@chapter]
      end
    else
      @voting_chapters = []
    end

    @voting_chapters
  end

  def show_winner_buttons_for(project, options = {})
    if @chapter.any_chapter?
      winnable_chapters = current_user.dean_chapters
    else
      winnable_chapters = [@chapter]
    end
    winnable_chapters.map do |chapter|
      link = link_to(project_winner_path(project, :chapter_id => chapter.id), :remote => true, :method => (project.winner? ? :delete : :post), :class => "mark-as-winner chapter-#{chapter.id}") do
        "#{options[:link_prefix]} #{I18n.t(".winner", name: chapter.name, scope: "projects.project")}".html_safe
      end
      "#{options[:pre]}#{link}#{options[:post]}"
    end.join("").html_safe
  end

  def display_project_actions?(user, project)
    user.can_mark_winner?(project) || user.can_edit_project?(project)
  end

  def checked_attribute_if(value)
    if value
      'checked="checked"'.html_safe
    else
      ''
    end
  end

  def s3_uploader_available?
    ENV['AWS_BUCKET'].present?
  end

  def comment_visibility_icon(comment)
    tag.i(class: "icon icon-#{comment_visibility_class(comment)} comment__visible-icon", title: comment.viewable_by)
  end

  def comment_visibility_class(comment)
    case comment.viewable_by
    when "myself" then
      "user"
    when "chapter" then
      "group"
    when "anyone" then
      "globe"
    end
  end
end
