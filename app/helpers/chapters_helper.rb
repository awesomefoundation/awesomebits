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

  def link_if_not_blank(url, css_class)
    if url.present?
      link_to("", url, :class => css_class)
    end
  end

  def email_link(chapter)
    if chapter.email_address.present?
      mail_to chapter.email_address, '', :class => [:external, :email]
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

  def about_class(chapter)
    chapter.rss_feed_url.present? ? "half" : ""
  end
end
