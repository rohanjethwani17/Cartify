FactoryBot.define do
  factory :inventory_level do
    variant
    location
    available { 100 }
    committed { 0 }
    incoming { 0 }
  end
end
