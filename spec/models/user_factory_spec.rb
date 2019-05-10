require 'spec_helper'

describe UserFactory do
  let(:factory) { UserFactory.new(user_attributes) }
  let(:chapter) { FactoryGirl.create(:chapter) }

  describe "#create" do
    let(:user_attributes) {{
      :first_name => "Joe",
      :last_name => "Schmoe",
      :email => "someone@example.com",
      :chapter => chapter,
      :password => "12345"
    }}

    it "saves a User and the Role between the User and the Chapter" do
      factory.create
      user = factory.user

      expect(user).not_to be_a_new_record
      expect(user.roles.size).to eq(1)
      expect(user.chapters.size).to eq(1)
      expect(user.chapters.first).to eq(chapter)
      expect(user.roles.first.name).to eq("trustee")
    end

    it "creates a new Role, but not a User, if the User exists already" do
      existing_user = FactoryGirl.create(:user, :email => user_attributes[:email])

      factory.create
      user = factory.user

      expect(user).to eq(existing_user)
      expect(user.roles.size).to eq(1)
      expect(user.chapters.size).to eq(1)
      expect(user.chapters.first).to eq(chapter)
      expect(user.roles.first.name).to eq("trustee")
    end

    it "uses an existing Role if it exists already" do
      existing_user = FactoryGirl.create(:user, :email => user_attributes[:email])
      existing_role = FactoryGirl.create(:role, :user => existing_user, :chapter => chapter)

      factory.create
      role = factory.role

      expect(role).to eq(existing_role)
    end
  end

  context "create a dean" do
    let(:user_attributes) {
      {
        first_name: "Joe",
        last_name: "Schmoe",
        email: "someone@example.com",
        chapter: chapter,
        password: "12345",
        role_name: "dean"
      }
    }

    it "creates a new User with a dean Role" do
      factory.create
      user = factory.user

      expect(user).not_to be_a_new_record
      expect(user.roles.size).to eq(1)
      expect(user.chapters.size).to eq(1)
      expect(user.chapters.first).to eq(chapter)
      expect(user.roles.first.name).to eq("dean")
    end
  end
end
