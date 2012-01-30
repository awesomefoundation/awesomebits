RSpec::Matchers.define :show_the_flash do |expected|
  chain :containing do |message|
    @message = message
  end

  match do |actual|
    actual.should have_css("#flash #flash_#{expected}:contains('#{@message}')")
  end

  failure_message_for_should do |actual|
    %[Expected this content:\n#{actual.body}\n to have CSS matching "#flash #flash_#{expected}:contains('#{@message}')"]
  end
end
