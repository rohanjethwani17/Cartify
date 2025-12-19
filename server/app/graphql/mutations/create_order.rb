module Mutations
  class CreateOrder < BaseMutation
    argument :store_id, ID, required: true
    argument :input, Types::Inputs::OrderInput, required: true
    argument :idempotency_key, String, required: false,
                                       description: 'Unique key to prevent duplicate orders on retries'

    field :order, Types::OrderType, null: true
    field :errors, [String], null: false

    def resolve(store_id:, input:, idempotency_key: nil)
      require_auth!

      store = with_store(Store.find(store_id))
      authorize!(store, :show)

      result = Orders::CreateOrder.call(
        store: store,
        line_items: input.line_items.map { |li| { variant_id: li.variant_id, quantity: li.quantity } },
        email: input.email,
        shipping_address: input.shipping_address&.to_h || {},
        idempotency_key: idempotency_key,
        current_user: current_user
      )

      if result.success?
        { order: result.data, errors: [] }
      else
        { order: nil, errors: result.errors }
      end
    end
  end
end
