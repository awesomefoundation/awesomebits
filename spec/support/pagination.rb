module PaginationHelpers
  def go_to_next_page
    find('a.next_page[rel="next"]').click
  end
end

RSpec.configure do |c|
  c.include PaginationHelpers
end
