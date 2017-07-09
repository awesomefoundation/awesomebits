module PaginationHelpers
  def go_to_next_page
    find('a.next_page[rel="next"]').click
  end
end

RSpec.configure do |c|
  c.include PaginationHelpers

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  c.infer_spec_type_from_file_location!
end
