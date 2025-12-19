module Inventory
  class AdjustInventory < ApplicationService
    def initialize(variant:, location:, delta:, reason: nil, current_user: nil)
      super()
      @variant = variant
      @location = location
      @delta = delta
      @reason = reason
      @current_user = current_user
    end

    def call
      ActiveRecord::Base.transaction do
        # Find or create inventory level
        @inventory_level = InventoryLevel.find_or_initialize_by(
          variant: @variant,
          location: @location
        )

        previous_available = @inventory_level.available || 0
        new_available = previous_available + @delta

        return failure('Cannot reduce inventory below zero') if new_available.negative?

        @inventory_level.available = new_available
        @inventory_level.save!

        store = @location.store

        # Create audit log
        AuditLog.log(
          store: store,
          user: @current_user,
          action: 'adjust_inventory',
          resource: @inventory_level,
          changes: { available: [previous_available, new_available] },
          metadata: { reason: @reason, delta: @delta }
        )

        # Check for low stock and trigger alert
        check_low_stock_alert(store)

        success(@inventory_level)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end

    private

    def check_low_stock_alert(store)
      threshold = store.low_stock_threshold
      return unless @inventory_level.available <= threshold

      # Create alert
      alert = InventoryAlert.create_for_low_stock(@inventory_level, threshold)

      # Trigger subscription
      CartifySchema.subscriptions.trigger(
        :inventory_low,
        { store_id: store.id, threshold: threshold },
        alert
      )
    end
  end
end
