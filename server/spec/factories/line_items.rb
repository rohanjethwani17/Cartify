FactoryBot.define do
  factory :line_item do
    order
    variant
    title { variant&.product&.title || 'Test Product' }
    quantity { 1 }
    price { variant&.price || 29.99 }
    fulfilled_quantity { 0 }
  end
end
