require 'spec_helper'

describe UserFactory do
  describe "#create" do
    let(:chapter) { FactoryGirl.create(:chapter) }
    let(:user_attributes) {{
      :first_name => "Joe",
      :last_name => "Schmoe",
      :email => "someone@example.com",
      :chapter => chapter,
      :password => "12345"
    }}
    let(:factory) { UserFactory.new(user_attributes) }
    it "saves a User and the Role between the User and the Chapter" do
      user = factory.create

      user.should_not be_a_new_record
      user.should have(1).role
      user.should have(1).chapter
      user.chapters.first.should == chapter
      user.roles.first.name.should == "trustee"
    end
  end
end
