FactoryGirl.define do
  factory :team do
    name { Faker::Company.name }
    company
  end
end
