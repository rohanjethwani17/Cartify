module Mutations
  class UpdateProduct < BaseMutation
    argument :id, ID, required: true
    argument :input, Types::Inputs::ProductInput, required: true

    field :product, Types::ProductType, null: true
    field :errors, [String], null: false

    def resolve(id:, input:)
      require_auth!

      product = Product.find(id)
      with_store(product.store)
      authorize!(product, :update)

      result = Products::UpdateProduct.call(
        product: product,
        attributes: {
          title: input.title,
          description: input.description,
          status: input.status,
          product_type: input.product_type,
          vendor: input.vendor
        }.compact,
        current_user: current_user
      )

      if result.success?
        { product: result.data, errors: [] }
      else
        { product: nil, errors: result.errors }
      end
    end
  end
end
