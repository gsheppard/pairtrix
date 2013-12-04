FactoryGirl.define do
  factory :user do
    provider 'google_oauth2'
    uid 12345
    name 'Test User'
    email 'test@xxxx.com'
  end
end
