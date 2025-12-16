FactoryBot.define do
  factory :store do
    sequence(:name) { |n| "Store #{n}" }
    sequence(:slug) { |n| "store-#{n}" }
    low_stock_threshold { 10 }
  end
end
