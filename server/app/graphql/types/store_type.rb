module Types
  class StoreType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: false
    field :low_stock_threshold, Integer, null: false
    field :settings, GraphQL::Types::JSON, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    
    field :products, Types::ProductType.connection_type, null: false do
      argument :search, String, required: false
      argument :status, String, required: false
    end
    
    field :orders, Types::OrderType.connection_type, null: false do
      argument :search, String, required: false
      argument :status, String, required: false
    end
    
    field :locations, [Types::LocationType], null: false
    field :users, [Types::UserType], null: false
    field :inventory_alerts, [Types::InventoryAlertType], null: false do
      argument :reviewed, Boolean, required: false
    end
    
    field :order_aging_summary, Types::OrderAgingSummaryType, null: false
    
    def products(search: nil, status: nil)
      scope = object.products
      scope = scope.search(search) if search.present?
      scope = scope.where(status: status) if status.present?
      scope.order(created_at: :desc)
    end
    
    def orders(search: nil, status: nil)
      scope = object.orders
      scope = scope.search(search) if search.present?
      scope = scope.where(status: status) if status.present?
      scope.order(created_at: :desc)
    end
    
    def locations
      dataloader.with(Sources::AssociationSource, :locations).load(object)
    end
    
    def users
      dataloader.with(Sources::AssociationSource, :users).load(object)
    end
    
    def inventory_alerts(reviewed: nil)
      scope = object.inventory_alerts
      scope = reviewed.nil? ? scope : (reviewed ? scope.reviewed : scope.unreviewed)
      scope.recent
    end
    
    def order_aging_summary
      {
        zero_to_one_day: object.orders.unfulfilled.aged_0_1_days.count,
        two_to_three_days: object.orders.unfulfilled.aged_2_3_days.count,
        four_to_seven_days: object.orders.unfulfilled.aged_4_7_days.count,
        eight_plus_days: object.orders.unfulfilled.aged_8_plus_days.count
      }
    end
  end
end
