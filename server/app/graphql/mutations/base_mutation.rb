module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    # NOTE: input_object_class and object_class are not needed for RelayClassicMutation

    def current_user
      context[:current_user]
    end

    def current_store
      context[:current_store]
    end

    # Set current_store in context for a store-scoped operation
    # Call this immediately after loading the store
    def with_store(store)
      context[:current_store] = store
      store
    end

    def policy(record)
      policy_class = "#{record.class.name}Policy".constantize
      policy_class.new({ current_user: current_user, current_store: current_store }, record)
    rescue NameError
      ApplicationPolicy.new({ current_user: current_user, current_store: current_store }, record)
    end

    # Authorize with automatic store context setting
    # Derives store from record if not already set in context
    def authorize!(record, action)
      # Auto-set current_store from record if not already set
      if context[:current_store].nil? && record.respond_to?(:store)
        context[:current_store] = record.store
      elsif context[:current_store].nil? && record.is_a?(Store)
        context[:current_store] = record
      end

      return if policy(record).send("#{action}?")

      raise GraphQL::ExecutionError, "Not authorized to #{action} #{record.class.name}"
    end

    def require_auth!
      raise GraphQL::ExecutionError, 'Authentication required' unless current_user
    end
  end
end
