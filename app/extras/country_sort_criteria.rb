class CountrySortCriteria

  def initialize(country_priority)
    @country_priority = country_priority
  end

  def to_proc
    proc do |chapter|
      if(@country_priority.include? chapter.country)
        "#{@country_priority.index(chapter.country)} #{chapter.name}"
      else
        chapter.country
      end
    end
  end

end
