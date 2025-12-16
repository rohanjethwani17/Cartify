module Types
  class SubscriptionType < Types::BaseObject
    # Order created subscription
    field :order_created, Types::OrderType, null: false do
      description 'Triggered when a new order is created'
      argument :store_id, ID, required: true
    end
    
    # Low inventory alert subscription
    field :inventory_low, Types::InventoryAlertType, null: false do
      description 'Triggered when inventory drops below threshold'
      argument :store_id, ID, required: true
      argument :threshold, Integer, required: false
    end
    
    # Fulfillment status changed subscription
    field :fulfillment_status_changed, Types::OrderType, null: false do
      description 'Triggered when fulfillment status changes'
      argument :order_id, ID, required: true
    end
    
    # Sync progress subscription
    field :sync_progress_updated, Types::SyncProgressType, null: false do
      description 'Triggered when background sync job progress updates'
      argument :store_id, ID, required: true
    end
    
    def order_created(store_id:)
      # Verify user has access to store
      verify_store_access(store_id)
      object
    end
    
    def inventory_low(store_id:, threshold: nil)
      verify_store_access(store_id)
      object
    end
    
    def fulfillment_status_changed(order_id:)
      order = Order.find(order_id)
      verify_store_access(order.store_id)
      object
    end
    
    def sync_progress_updated(store_id:)
      verify_store_access(store_id)
      object
    end
    
    private
    
    def verify_store_access(store_id)
      return unless context[:current_user]
      
      store = Store.find_by(id: store_id)
      return if store.nil?
      
      unless context[:current_user].member_of?(store)
        raise GraphQL::ExecutionError, 'Not authorized to subscribe to this store'
      end
    end
  end
end
