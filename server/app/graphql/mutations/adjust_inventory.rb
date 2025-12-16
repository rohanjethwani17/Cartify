module Mutations
  class AdjustInventory < BaseMutation
    argument :variant_id, ID, required: true
    argument :location_id, ID, required: true
    argument :delta, Integer, required: true,
      description: 'Amount to adjust (positive to add, negative to subtract)'
    argument :reason, String, required: false
    
    field :inventory_level, Types::InventoryLevelType, null: true
    field :errors, [String], null: false
    
    def resolve(variant_id:, location_id:, delta:, reason: nil)
      require_auth!
      
      variant = Variant.find(variant_id)
      location = Location.find(location_id)
      
      context[:current_store] = location.store
      
      policy_context = ApplicationPolicy.new(
        { current_user: current_user, current_store: location.store },
        nil
      )
      
      unless policy_context.send(:can_write?)
        raise GraphQL::ExecutionError, 'Not authorized to adjust inventory'
      end
      
      result = Inventory::AdjustInventory.call(
        variant: variant,
        location: location,
        delta: delta,
        reason: reason,
        current_user: current_user
      )
      
      if result.success?
        { inventory_level: result.data, errors: [] }
      else
        { inventory_level: nil, errors: result.errors }
      end
    end
  end
end
