module ApplicationHelper
  def extract_timeframe
    start_date = params[:start].blank? ? nil : Date.strptime(params[:start], "%Y-%m-%d")
    end_date =   params[:end].blank?   ? nil : Date.strptime(params[:end],   "%Y-%m-%d")
    [start_date, end_date]
  end
  def display_country?(country)
    if(!defined?(@current_country) || country != @current_country)
      @current_country = country
      true
    else
      false
    end
  end
end
