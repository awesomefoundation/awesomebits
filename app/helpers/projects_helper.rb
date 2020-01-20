module ProjectsHelper
  def selectable_chapters_for(user)
    any_chapter = Chapter.where(:name => "Any").first
    if user.admin?
      [any_chapter] + Chapter.where("name != 'Any'").order(:name)
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

  def display_uploader?(uploader)
    if s3_uploader_available?
      if params[:uploader]
        uploader.to_s == params[:uploader]

      else
        uploader.to_s == "s3"
      end

    else
      uploader.to_s == "classic"
    end
  end

  def comment_visibility_icon(comment)
    icon = case comment.viewable_by
           when "myself" then
             "user"
           when "chapter" then
             "group"
           when "anyone" then
             "globe"
           end

    tag.i(class: "icon icon-#{icon} comment__visible-icon", title: comment.viewable_by)
  end
end
