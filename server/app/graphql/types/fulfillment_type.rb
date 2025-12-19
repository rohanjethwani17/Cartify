module Types
  class FulfillmentType < Types::BaseObject
    field :id, ID, null: false
    field :status, String, null: false
    field :tracking_company, String, null: true
    field :tracking_number, String, null: true
    field :tracking_url, String, null: true
    field :shipped_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :location, Types::LocationType, null: true

    def location
      return nil unless object.location_id

      dataloader.with(Sources::RecordSource, Location).load(object.location_id)
    end
  end
end
