FactoryGirl.define do
  factory :company_membership do
    company
    user
    role 'member'
  end
end
