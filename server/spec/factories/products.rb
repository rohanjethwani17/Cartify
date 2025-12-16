FactoryBot.define do
  factory :product do
    store
    sequence(:title) { |n| "Product #{n}" }
    description { 'A great product' }
    status { 'active' }
    product_type { 'General' }
    vendor { 'TestVendor' }
  end
end
