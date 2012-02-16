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

  def headlines(chapter, num_items = 5)
    Headline.new(RSS.new(chapter.rss_feed_url).raw_xml).top(num_items)
  end
end
