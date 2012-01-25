RSpec::Matchers.define :have_delivered_email do |expected|
  match do |actual|
    actual.delivery_count_for(expected).should == 1
    actual.delivery_made_for(expected).should be_true
  end
end
