FactoryGirl.define do
  factory :membership_request do
    company
    user
    status 'Pending'
  end
end
