module Types
  class InventoryAlertType < Types::BaseObject
    field :id, ID, null: false
    field :threshold, Integer, null: false
    field :current_level, Integer, null: false
    field :reviewed, Boolean, null: false
    field :reviewed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    
    field :variant, Types::VariantType, null: false
    field :location, Types::LocationType, null: false
    field :reviewed_by, Types::UserType, null: true
    
    def variant
      dataloader.with(Sources::RecordSource, Variant).load(object.variant_id)
    end
    
    def location
      dataloader.with(Sources::RecordSource, Location).load(object.location_id)
    end
    
    def reviewed_by
      return nil unless object.reviewed_by_id
      dataloader.with(Sources::RecordSource, User).load(object.reviewed_by_id)
    end
  end
end
