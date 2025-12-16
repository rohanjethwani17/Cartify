FactoryBot.define do
  factory :location do
    store
    sequence(:name) { |n| "Location #{n}" }
    city { 'San Francisco' }
    province { 'CA' }
    country { 'US' }
    active { true }
  end
end
