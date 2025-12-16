module Types
  class BaseObject < GraphQL::Schema::Object
    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
    field_class Types::BaseField
    
    def current_user
      context[:current_user]
    end
    
    def current_store
      context[:current_store]
    end
    
    def policy(record)
      policy_class = "#{record.class.name}Policy".constantize
      policy_class.new({ current_user: current_user, current_store: current_store }, record)
    rescue NameError
      ApplicationPolicy.new({ current_user: current_user, current_store: current_store }, record)
    end
    
    def authorize!(record, action)
      unless policy(record).send("#{action}?")
        raise GraphQL::ExecutionError, "Not authorized to #{action} #{record.class.name}"
      end
    end
  end
end
