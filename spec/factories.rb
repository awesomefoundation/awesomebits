FactoryGirl.define do
  sequence(:email) {|n| "user#{n}@example.com" }
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

  factory :invitation do
    email
    chapter
    inviter
  end
end
