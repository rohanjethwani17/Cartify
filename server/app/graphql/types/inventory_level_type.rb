module Types
  class InventoryLevelType < Types::BaseObject
    field :id, ID, null: false
    field :available, Integer, null: false
    field :committed, Integer, null: false
    field :incoming, Integer, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :variant, Types::VariantType, null: false
    field :location, Types::LocationType, null: false

    def variant
      dataloader.with(Sources::RecordSource, Variant).load(object.variant_id)
    end

    def location
      dataloader.with(Sources::RecordSource, Location).load(object.location_id)
    end
  end
end
