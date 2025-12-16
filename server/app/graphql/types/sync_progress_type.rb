module Types
  class SyncProgressType < Types::BaseObject
    field :store_id, ID, null: false
    field :job_id, String, null: false
    field :status, String, null: false
    field :progress, Integer, null: false
    field :total, Integer, null: false
    field :message, String, null: true
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true
  end
end
