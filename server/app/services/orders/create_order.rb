module Orders
  class CreateOrder < ApplicationService
    def initialize(store:, line_items:, email: nil, shipping_address: {}, idempotency_key: nil, current_user: nil)
      super()
      @store = store
      @line_items = line_items
      @email = email
      @shipping_address = shipping_address
      @idempotency_key = idempotency_key
      @current_user = current_user
    end

    def call
      # Check idempotency
      if @idempotency_key.present?
        existing_order = Order.find_by(idempotency_key: @idempotency_key)
        return success(existing_order) if existing_order
      end

      ActiveRecord::Base.transaction do
        # Create order
        @order = @store.orders.build(
          email: @email,
          shipping_address: @shipping_address,
          idempotency_key: @idempotency_key,
          status: 'pending',
          fulfillment_status: 'unfulfilled',
          financial_status: 'pending'
        )

        # Validate and add line items
        @line_items.each do |item|
          variant = Variant.joins(:product).find_by(
            id: item[:variant_id],
            products: { store_id: @store.id }
          )

          unless variant
            @errors << "Variant #{item[:variant_id]} not found"
            next
          end

          quantity = item[:quantity] || 1

          # Check inventory
          total_available = variant.total_available
          if total_available < quantity
            @errors << "Insufficient inventory for #{variant.display_name}"
            next
          end

          @order.line_items.build(
            variant: variant,
            quantity: quantity
          )
        end

        return failure if @errors.any?

        # Calculate totals
        @order.calculate_totals
        @order.save!

        # Reserve inventory
        reserve_inventory!

        # Create audit log
        AuditLog.log(
          store: @store,
          user: @current_user,
          action: 'create',
          resource: @order,
          changes: { status: [nil, 'pending'] }
        )

        # Trigger subscription
        CartifySchema.subscriptions.trigger(
          :order_created,
          { store_id: @store.id },
          @order
        )

        success(@order)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end

    private

    def reserve_inventory!
      @order.line_items.each do |line_item|
        # Find best location with available inventory
        inventory_level = line_item.variant.inventory_levels
                                   .where('available >= ?', line_item.quantity)
                                   .order(available: :desc)
                                   .first

        inventory_level&.reserve(line_item.quantity)
      end
    end
  end
end
