module Types
  class AuditLogType < Types::BaseObject
    field :id, ID, null: false
    field :action, String, null: false
    field :resource_type, String, null: false
    field :resource_id, ID, null: false
    field :changes, GraphQL::Types::JSON, null: false
    field :metadata, GraphQL::Types::JSON, null: false
    field :ip_address, String, null: true
    field :user_agent, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    
    field :user, Types::UserType, null: true
    
    def user
      return nil unless object.user_id
      dataloader.with(Sources::RecordSource, User).load(object.user_id)
    end
  end
end
