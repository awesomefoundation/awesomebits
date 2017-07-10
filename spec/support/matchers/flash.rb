RSpec::Matchers.define :show_the_flash do |expected|
  match do |actual|
    expect(actual).to have_selector("#flash #flash_#{expected}")
  end

  failure_message do |actual|
    %[Expected this content:\n#{actual.body}\n to have an element matching "#flash #flash_#{expected}"]
  end
end
