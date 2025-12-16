module Types
  class LocationType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :address1, String, null: true
    field :address2, String, null: true
    field :city, String, null: true
    field :province, String, null: true
    field :country, String, null: true
    field :zip, String, null: true
    field :active, Boolean, null: false
    field :full_address, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    
    field :inventory_levels, [Types::InventoryLevelType], null: false
    
    def inventory_levels
      dataloader.with(Sources::AssociationSource, :inventory_levels).load(object)
    end
    
    def full_address
      object.full_address
    end
  end
end
