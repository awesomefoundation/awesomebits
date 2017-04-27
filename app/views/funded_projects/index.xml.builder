atom_feed(language: I18n.locale) do |feed|
  feed.title t('feed.title')
  feed.updated @projects[0].updated_at unless @projects.empty?

  @projects.each do |project|
    feed.entry(project, :published => project.funded_on) do |entry|
      entry.title "#{project.chapter.name} – #{project.title}"
      entry.content(project.funded_description, type: 'html')

      if project.has_images? && mime_type = MIME::Types.type_for(project.primary_image.url).first
        entry.link(href: image_url(project.primary_image.url), rel: 'enclosure', type: mime_type)
      end

      entry.author do |author|
        author.name project.name
      end
    end
  end
end
