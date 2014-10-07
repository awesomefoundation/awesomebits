RSpec::Matchers.define :show_the_flash do |expected|
  match do |actual|
    actual.should have_selector("#flash #flash_#{expected}")
  end

  failure_message_for_should do |actual|
    %[Expected this content:\n#{actual.body}\n to have an element matching "#flash #flash_#{expected}"]
  end
end
