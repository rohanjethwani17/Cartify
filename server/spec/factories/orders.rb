FactoryBot.define do
  factory :order do
    store
    sequence(:order_number) { |n| "ORD-#{n.to_s.rjust(6, '0')}" }
    email { 'customer@example.com' }
    status { 'pending' }
    fulfillment_status { 'unfulfilled' }
    financial_status { 'pending' }
  end
end
