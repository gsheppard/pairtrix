FactoryGirl.define do
  factory :team do
    sequence(:name) { |n| "#{Faker::Company.name}-#{n}" }
    company
  end
end
