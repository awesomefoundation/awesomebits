RSpec.configure do |config|
  config.before(:each, type: :view) do
    view.stubs(:embed?).returns(false)
  end
end
