require 'spec_helper'

describe UserFactory do
  describe "#create" do
    let(:chapter) { create(:chapter) }
    let(:user_attributes) {{
      first_name: "Joe",
      last_name: "Schmoe",
      email: "someone@example.com",
      chapter: chapter,
      password: "12345"
    }}
    let(:factory) { UserFactory.new(user_attributes) }
    it "saves a User and the Role between the User and the Chapter" do
      factory.create
      user = factory.user

      user.should_not be_a_new_record
      user.should have(1).role
      user.should have(1).chapter
      user.chapters.first.should == chapter
      user.roles.first.name.should == "trustee"
    end
    it "creates a new Role, but not a User, if the User exists already" do
      existing_user = create(:user, email: user_attributes[:email])

      factory.create
      user = factory.user

      user.should == existing_user
      user.should have(1).role
      user.should have(1).chapter
      user.chapters.first.should == chapter
      user.roles.first.name.should == "trustee"
    end
    it "uses an existing Role if it exists already" do
      existing_user = create(:user, email: user_attributes[:email])
      existing_role = create(:role, user: existing_user, chapter: chapter)

      factory.create
      role = factory.role

      role.should == existing_role
    end
  end
end
