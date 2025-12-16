class CartifySchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)
  subscription(Types::SubscriptionType)
  
  # Use dataloader for batching
  use GraphQL::Dataloader
  
  # ActionCable subscriptions with Redis
  use GraphQL::Subscriptions::ActionCableSubscriptions,
    redis: Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
  
  # Query depth limit
  max_depth 15
  
  # Complexity budget
  max_complexity 300
  
  # Default page size
  default_max_page_size 50
  
  # Error handling
  rescue_from(ActiveRecord::RecordNotFound) do |err, obj, args, ctx, field|
    raise GraphQL::ExecutionError, "#{field.type.unwrap.graphql_name} not found"
  end
  
  rescue_from(ActiveRecord::RecordInvalid) do |err, obj, args, ctx, field|
    raise GraphQL::ExecutionError, err.record.errors.full_messages.join(', ')
  end
  
  # Union/Interface resolution
  def self.resolve_type(abstract_type, obj, ctx)
    case obj
    when Order then Types::OrderType
    when Product then Types::ProductType
    when Variant then Types::VariantType
    else
      raise "Unknown type: #{obj.class}"
    end
  end
  
  # Object identification for Relay
  def self.object_from_id(id, ctx)
    type, db_id = GraphQL::Schema::UniqueWithinType.decode(id)
    type.constantize.find(db_id)
  end
  
  def self.id_from_object(object, type_definition, ctx)
    GraphQL::Schema::UniqueWithinType.encode(object.class.name, object.id)
  end
end
