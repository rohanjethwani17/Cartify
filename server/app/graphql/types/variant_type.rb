module Types
  class VariantType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :sku, String, null: true
    field :price, Float, null: false
    field :compare_at_price, Float, null: true
    field :position, Integer, null: false
    field :requires_shipping, Boolean, null: false
    field :weight, Float, null: true
    field :weight_unit, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :product, Types::ProductType, null: false
    field :inventory_levels, [Types::InventoryLevelType], null: false
    field :total_available, Integer, null: false
    field :display_name, String, null: false

    def product
      dataloader.with(Sources::RecordSource, Product).load(object.product_id)
    end

    def inventory_levels
      dataloader.with(Sources::AssociationSource, :inventory_levels).load(object)
    end

    def total_available
      object.total_available
    end

    def display_name
      object.display_name
    end
  end
end
