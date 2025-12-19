module Types
  class OrderType < Types::BaseObject
    field :id, ID, null: false
    field :order_number, String, null: false
    field :email, String, null: true
    field :status, String, null: false
    field :fulfillment_status, String, null: false
    field :financial_status, String, null: false
    field :subtotal, Float, null: false
    field :total_tax, Float, null: false
    field :total_shipping, Float, null: false
    field :total_price, Float, null: false
    field :currency, String, null: false
    field :shipping_address, GraphQL::Types::JSON, null: true
    field :billing_address, GraphQL::Types::JSON, null: true
    field :note, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :store, Types::StoreType, null: false
    field :line_items, [Types::LineItemType], null: false
    field :fulfillments, [Types::FulfillmentType], null: false

    def store
      dataloader.with(Sources::RecordSource, Store).load(object.store_id)
    end

    def line_items
      dataloader.with(Sources::AssociationSource, :line_items).load(object)
    end

    def fulfillments
      dataloader.with(Sources::AssociationSource, :fulfillments).load(object)
    end
  end
end
