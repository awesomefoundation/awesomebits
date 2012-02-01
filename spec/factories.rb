FactoryGirl.define do
  sequence(:email) {|n| "user#{n}@example.com" }
  sequence(:title) {|n| "Something Awesome ##{n}" }
  sequence(:index)

  factory :chapter do
    name "Chapter for Generic Location ##{FactoryGirl.generate(:index)}"
  end

  factory :user, :aliases => [:inviter, :invitee] do
    first_name "Joe"
    last_name "Schmoe"
    email
    password "12345"
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
    chapter
    inviter
  end

  factory :project do
    name "Joe Schmoe"
    title
    email
    description "I am awesome."
    use "I will do awesome."
    chapter
  end
end
