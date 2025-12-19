module Mutations
  class UpdateStoreSettings < BaseMutation
    argument :store_id, ID, required: true
    argument :low_stock_threshold, Integer, required: false
    argument :settings, GraphQL::Types::JSON, required: false

    field :store, Types::StoreType, null: true
    field :errors, [String], null: false

    def resolve(store_id:, low_stock_threshold: nil, settings: nil)
      require_auth!

      store = with_store(Store.find(store_id))
      authorize!(store, :update_settings)

      updates = {}
      updates[:low_stock_threshold] = low_stock_threshold if low_stock_threshold
      updates[:settings] = settings if settings

      if store.update(updates)
        # Create audit log
        AuditLog.log(
          store: store,
          user: current_user,
          action: 'update_settings',
          resource: store,
          changes: updates
        )

        { store: store, errors: [] }
      else
        { store: nil, errors: store.errors.full_messages }
      end
    end
  end
end
