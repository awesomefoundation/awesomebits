module ApplicationHelper
  def extract_timeframe
    start_date = params[:start].blank? ? nil : Date.strptime(params[:start], "%Y-%m-%d")
    end_date =   params[:end].blank?   ? nil : Date.strptime(params[:end],   "%Y-%m-%d")
    [start_date, end_date]
  end

  def display_country?(country)
    if(!defined?(@current_country))
      @first_country = true
    else
      @first_country = false
    end
    if(!defined?(@current_country) || country != @current_country)
      @current_country = country
    end
  end

  def funding_amount_for(winner_count)
    number_with_delimiter(winner_count * 1000, :delimiter => I18n.t("number.delimiter"),
                                               :separator => I18n.t("number.separator"))
  end

  def markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
    markdown.render(text).html_safe unless text.nil?
  end

  def image_url(image)
    (URI.parse(root_url) + image_path(image)).to_s
  end

  def meta_tag(tag_name, content, options = {})
    content_tag = "meta_#{tag_name}".to_sym

    tag :meta, options.merge(:content => content_for?(content_tag) ? content_for(content_tag) : content)
  end

end
