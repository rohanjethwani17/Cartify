FactoryBot.define do
  factory :variant do
    product
    sequence(:title) { |n| "Variant #{n}" }
    sequence(:sku) { |n| "SKU-#{n}" }
    price { 29.99 }
  end
end
