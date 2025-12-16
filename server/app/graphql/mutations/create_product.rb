module Mutations
  class CreateProduct < BaseMutation
    argument :store_id, ID, required: true
    argument :input, Types::Inputs::ProductInput, required: true
    
    field :product, Types::ProductType, null: true
    field :errors, [String], null: false
    
    def resolve(store_id:, input:)
      require_auth!
      
      store = Store.find(store_id)
      context[:current_store] = store
      authorize!(store, :show)
      
      result = Products::CreateProduct.call(
        store: store,
        title: input.title,
        attributes: {
          description: input.description,
          status: input.status,
          product_type: input.product_type,
          vendor: input.vendor
        },
        variants: input.variants&.map(&:to_h) || [],
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
