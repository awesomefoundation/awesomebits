module ProjectsHelper
  def selectable_chapters_for(user)
    any_chapter = Chapter.where(:name => "Any").first
    if user.admin?
      [any_chapter] + Chapter.where("name != 'Any'").order(:name)
    else
      [any_chapter] + user.chapters.order(:name)
    end
  end

  def show_winner_buttons_for(project)
    if @chapter.any_chapter?
      winnable_chapters = current_user.dean_chapters
    else
      winnable_chapters = [@chapter]
    end
    winnable_chapters.map do |chapter|
      link_to(I18n.t(".winner", name: chapter.name, scope: "projects.project"), project_winner_path(project, :chapter_id => chapter.id), :remote => true, :method => (project.winner? ? :delete : :post), :class => "mark-as-winner chapter-#{chapter.id}")
    end.join("").html_safe
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
end
