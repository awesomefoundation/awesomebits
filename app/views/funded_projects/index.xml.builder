atom_feed(language: I18n.locale, "xmlns:awesome" => "http://www.awesomefoundation.org/") do |feed|
  feed.title t('feed.title')
  feed.updated @projects[0].updated_at unless @projects.empty?

  @projects.each do |project|
    feed.entry(project, :published => project.funded_on) do |entry|
      entry.title "#{project.chapter.name} – #{project.title}"
      entry.content(project.funded_description, type: 'html') unless project.funded_description.blank?

      if mime_type = MIME::Types.type_for(project.primary_image.url).first
        entry.link(href: image_url(project.primary_image.url), rel: 'enclosure', type: mime_type)
      end

      entry.author do |author|
        author.name project.name
      end

      entry.tag!("awesome:details") do |awesome|
        awesome.project do |p|
          p.name project.title
          p.url  project.url unless project.url.blank?
        end

        awesome.chapter do |chapter|
          chapter.country project.chapter.country
          chapter.name    project.chapter.name
          chapter.url     chapter_url(project.chapter)
        end
      end
    end
  end
end
