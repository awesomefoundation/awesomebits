class CountryOptions
  def self.countries_for_select(options = nil)
    ApplicationController.helpers.options_for_select(["Worldwide", separator] + COUNTRIES, { disabled: separator }.merge(options))
  end

  private
  def self.separator
    "-" * 20
  end
end
