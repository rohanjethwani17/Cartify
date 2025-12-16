module Types
  class LineItemType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :variant_title, String, null: true
    field :sku, String, null: true
    field :quantity, Integer, null: false
    field :price, Float, null: false
    field :total_discount, Float, null: false
    field :requires_shipping, Boolean, null: false
    field :fulfilled_quantity, Integer, null: false
    field :total, Float, null: false
    field :remaining_to_fulfill, Integer, null: false
    
    field :variant, Types::VariantType, null: false
    
    def variant
      dataloader.with(Sources::RecordSource, Variant).load(object.variant_id)
    end
    
    def total
      object.total
    end
    
    def remaining_to_fulfill
      object.remaining_to_fulfill
    end
  end
end
