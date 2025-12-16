module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :name, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :stores, [Types::StoreType], null: false
    
    def stores
      dataloader.with(Sources::AssociationSource, :stores).load(object)
    end
  end
end
