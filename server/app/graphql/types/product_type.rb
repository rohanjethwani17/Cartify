module Types
  class ProductType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :status, String, null: false
    field :product_type, String, null: true
    field :vendor, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :store, Types::StoreType, null: false
    field :variants, [Types::VariantType], null: false
    field :total_inventory, Integer, null: false

    def store
      dataloader.with(Sources::RecordSource, Store).load(object.store_id)
    end

    def variants
      dataloader.with(Sources::AssociationSource, :variants).load(object)
    end

    def total_inventory
      object.total_inventory
    end
  end
end
