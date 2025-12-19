module Mutations
  class UpdateFulfillmentStatus < BaseMutation
    argument :order_id, ID, required: true
    argument :status, String, required: true
    argument :tracking_number, String, required: false
    argument :tracking_company, String, required: false
    argument :tracking_url, String, required: false

    field :order, Types::OrderType, null: true
    field :errors, [String], null: false

    def resolve(order_id:, status:, tracking_number: nil, tracking_company: nil, tracking_url: nil)
      require_auth!

      order = Order.find(order_id)
      with_store(order.store)
      authorize!(order, :update_fulfillment)

      result = Orders::UpdateFulfillmentStatus.call(
        order: order,
        status: status,
        tracking_info: {
          tracking_number: tracking_number,
          tracking_company: tracking_company,
          tracking_url: tracking_url
        }.compact,
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
