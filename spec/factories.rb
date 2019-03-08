FactoryGirl.define do
  sequence(:email) {|n| "user#{n}@example.com" }
  sequence(:title) {|n| "Something Awesome ##{n}" }
  sequence(:index)

  factory :chapter do
    name { "Chapter for Generic Location ##{FactoryGirl.generate(:index)}" }
    description { "This is a description." }
    country { "United States" }

    factory :inactive_chapter do
      inactive_at { Time.zone.now }
    end
  end

  factory :user, :aliases => [:inviter, :invitee] do
    first_name "Joe"
    last_name "Schmoe"
    email
    password "12345"
    url "http://www.example.com/"

    factory :admin do
      admin true
    end

    factory :user_with_dean_role do
      after(:create) do |user|
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

    after(:build) do |invitation, proxy|
      invitation.chapter = invitation.inviter.chapters.first
    end
  end

  factory :project do
    name "Joe Schmoe"
    title
    email
    url "http://something.com"
    about_project "I am awesome."
    about_me "I am a meat popsicle."
    use_for_money "I will do awesome."
    chapter

    factory :project_with_rss_feed do
      rss_feed_url Rails.root.join('spec', 'support', 'feed.xml').to_s
    end

    factory :winning_project do
      sequence(:funded_on) { |n| (3000-n.to_i).days.ago }
    end
  end

  factory :vote do
    user
    project
  end

  factory :photo do
    project
    image { File.new(Rails.root.join("spec", "support", "fixtures", "1.jpg")) }

    factory :utf8_photo do
      image { File.new(Rails.root.join("spec", "support", "fixtures", "מדהים.png"))}
    end

    factory :pdf do
      image { File.new(Rails.root.join("spec", "support", "fixtures", "1.pdf")) }
    end
  end
end
