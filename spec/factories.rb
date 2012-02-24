FactoryGirl.define do
  sequence(:email) {|n| "user#{n}@example.com" }
  sequence(:title) {|n| "Something Awesome ##{n}" }
  sequence(:index)

  factory :chapter do
    name { "Chapter for Generic Location ##{FactoryGirl.generate(:index)}" }
    description { "This is a description." }
  end

  factory :user, :aliases => [:inviter, :invitee] do
    first_name "Joe"
    last_name "Schmoe"
    email
    password "12345"

    factory :user_with_dean_role do
      after_create do |user|
        FactoryGirl.create(:role, :user => user, :name => "dean")
        user.reload
      end
    end
  end

  factory :role do
    user
    chapter

    trait :trustee do
      name "trustee"
    end
  end

  factory :invitation do
    email
    association :inviter, :factory => :user_with_dean_role

    after_build do |invitation, proxy|
      invitation.chapter = invitation.inviter.chapters.first
    end
  end

  factory :project do
    name "Joe Schmoe"
    title
    email
    url "http://something.com"
    description "I am awesome."
    use "I will do awesome."
    chapter
    factory :full_project do
      rss_feed_url Rails.root.join('spec', 'support', 'feed.xml').to_s
    end
  end

  factory :vote do
    user
    project
  end

  factory :photo do
    project
    image { File.new(Rails.root.join("spec", "support", "fixtures", "1.JPG")) }
  end
end
