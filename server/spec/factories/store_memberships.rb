FactoryBot.define do
  factory :store_membership do
    store
    user
    role { 'staff' }
    
    trait :owner do
      role { 'owner' }
    end
    
    trait :read_only do
      role { 'read_only' }
    end
  end
end
