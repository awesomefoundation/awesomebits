atom_feed do |feed|
  feed.title t('feed.title')
  feed.updated @projects[0].updated_at unless @projects.empty?

  @projects.each do |project|
    feed.entry(project) do |entry|
      entry.title "#{project.chapter.name} – #{project.title}"
      entry.content(project.about_project, type: 'html')
      entry.link(href: project.primary_image.url, rel: 'enclosure', type: 'image/jpeg')

      entry.author do |author|
        author.name project.name
      end
    end
  end
end
