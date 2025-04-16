module MarkdownHandler
  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  def self.call(template, source)
    compiled_source = erb.call(template, source)
    "Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, no_intra_emphasis: true, autolink: true).render(begin;#{compiled_source};end.to_s).html_safe"
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler
