module Mutations
  class MarkInventoryAlertReviewed < BaseMutation
    argument :alert_id, ID, required: true
    
    field :inventory_alert, Types::InventoryAlertType, null: true
    field :errors, [String], null: false
    
    def resolve(alert_id:)
      require_auth!
      
      alert = InventoryAlert.find(alert_id)
      context[:current_store] = alert.store
      
      policy_context = ApplicationPolicy.new(
        { current_user: current_user, current_store: alert.store },
        nil
      )
      
      unless policy_context.send(:can_write?)
        raise GraphQL::ExecutionError, 'Not authorized to mark alert as reviewed'
      end
      
      result = Inventory::MarkAlertReviewed.call(
        alert: alert,
        current_user: current_user
      )
      
      if result.success?
        { inventory_alert: result.data, errors: [] }
      else
        { inventory_alert: nil, errors: result.errors }
      end
    end
  end
end
