module Orders
  class UpdateFulfillmentStatus < ApplicationService
    def initialize(order:, status:, tracking_info: {}, current_user: nil)
      super()
      @order = order
      @status = status
      @tracking_info = tracking_info
      @current_user = current_user
    end
    
    def call
      previous_status = @order.fulfillment_status
      
      ActiveRecord::Base.transaction do
        case @status
        when 'fulfilled'
          fulfill_order!
        when 'partial'
          partial_fulfill!
        when 'unfulfilled'
          # Reset to unfulfilled
          @order.update!(fulfillment_status: 'unfulfilled')
        end
        
        # Create audit log
        AuditLog.log(
          store: @order.store,
          user: @current_user,
          action: 'update_fulfillment',
          resource: @order,
          changes: { fulfillment_status: [previous_status, @order.fulfillment_status] }
        )
        
        # Trigger subscription
        CartifySchema.subscriptions.trigger(
          :fulfillment_status_changed,
          { order_id: @order.id },
          @order
        )
        
        success(@order)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end
    
    private
    
    def fulfill_order!
      fulfillment = @order.fulfillments.create!(
        status: 'success',
        tracking_number: @tracking_info[:tracking_number],
        tracking_company: @tracking_info[:tracking_company],
        tracking_url: @tracking_info[:tracking_url],
        shipped_at: Time.current
      )
      
      # Mark all items as fulfilled
      @order.line_items.each do |line_item|
        line_item.update!(fulfilled_quantity: line_item.quantity)
        
        # Release committed inventory
        line_item.variant.inventory_levels.each do |il|
          next unless il.committed > 0
          
          to_fulfill = [il.committed, line_item.quantity].min
          il.fulfill(to_fulfill)
        end
      end
      
      @order.update!(fulfillment_status: 'fulfilled', status: 'fulfilled')
    end
    
    def partial_fulfill!
      @order.update!(fulfillment_status: 'partial')
    end
  end
end
