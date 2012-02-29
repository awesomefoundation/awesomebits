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

  def full_title(page_title)
    base_title = "The Awesome Foundation"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def funding_amount_for(winner_count)
    number_with_delimiter(winner_count * 1000, :delimiter => I18n.t("number.delimiter"),
                                               :separator => I18n.t("number.separator"))
  end
end
