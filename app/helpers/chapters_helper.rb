module ChaptersHelper

  def can_manage_chapter?(chapter)
    if current_user && current_user.can_manage_chapter?(chapter)
      true
    else
      false
    end
  end

  def extra_questions_json(chapter)
    [chapter.extra_question_1, chapter.extra_question_2, chapter.extra_question_3].reject(&:blank?).to_json.html_safe
  end

  def rss(rss_feed_url)
    return [] if rss_feed_url.blank?
    @fetchers = {}
    @rsses = {}
    @fetchers[rss_feed_url] ||= fetch(rss_feed_url)
    @rsses[rss_feed_url]    ||= RSS.new(@fetchers[rss_feed_url]).headlines
  end

  def fetch(url)
    Fetcher.new(url).to_s
  end

  def has_headlines?(rss_feed_url = nil)
    rss(rss_feed_url).length > 0
  end

  def headlines(rss_feed_url = nil, num_items = 5)
    rss(rss_feed_url).first(num_items)
  end

  def link_if_not_blank(url, css_class)
    if url.present?
      link_to("", url, :class => css_class)
    end
  end

  def blog_link(chapter)
    link_if_not_blank(chapter.blog_url, "external blog")
  end

  def facebook_link(chapter)
    link_if_not_blank(chapter.facebook_url, "external facebook")
  end

  def twitter_link(chapter)
    link_if_not_blank(chapter.twitter_url, "external twitter")
  end
end
