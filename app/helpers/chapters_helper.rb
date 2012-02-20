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

  def headlines(rss_feed_url = '', num_items = 5)
    return [] if rss_feed_url.blank?
    RSS.new(fetch(rss_feed_url)).headlines.first(num_items)
  end

  def fetch(url)
    Fetcher.new(url).to_s
  end
end
