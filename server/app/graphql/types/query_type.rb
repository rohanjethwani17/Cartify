module Types
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField
    
    field :me, Types::UserType, null: true,
      description: 'Current authenticated user'
    
    field :store, Types::StoreType, null: true do
      description 'Fetch a store by ID'
      argument :id, ID, required: true
    end
    
    field :products, Types::ProductType.connection_type, null: false do
      description 'Paginated list of products'
      argument :store_id, ID, required: true
      argument :search, String, required: false
      argument :status, String, required: false
    end
    
    field :orders, Types::OrderType.connection_type, null: false do
      description 'Paginated list of orders'
      argument :store_id, ID, required: true
      argument :status, String, required: false
      argument :search, String, required: false
    end
    
    field :low_stock_variants, [Types::VariantType], null: false do
      description 'Variants with inventory below threshold'
      argument :store_id, ID, required: true
      argument :threshold, Integer, required: false
    end
    
    field :order, Types::OrderType, null: true do
      description 'Fetch a single order'
      argument :id, ID, required: true
    end
    
    field :product, Types::ProductType, null: true do
      description 'Fetch a single product'
      argument :id, ID, required: true
    end
    
    def me
      current_user
    end
    
    def store(id:)
      store = Store.find_by(id: id)
      return nil unless store
      
      authorize!(store, :show)
      store
    end
    
    def products(store_id:, search: nil, status: nil)
      store = Store.find(store_id)
      authorize!(store, :show)
      
      scope = store.products
      scope = scope.search(search) if search.present?
      scope = scope.where(status: status) if status.present?
      scope.order(created_at: :desc)
    end
    
    def orders(store_id:, status: nil, search: nil)
      store = Store.find(store_id)
      authorize!(store, :show)
      
      scope = store.orders
      scope = scope.where(status: status) if status.present?
      scope = scope.search(search) if search.present?
      scope.order(created_at: :desc)
    end
    
    def low_stock_variants(store_id:, threshold: nil)
      store = Store.find(store_id)
      authorize!(store, :show)
      
      threshold ||= store.low_stock_threshold
      
      Variant
        .joins(product: :store)
        .where(products: { store_id: store_id })
        .low_stock(threshold)
    end
    
    def order(id:)
      order = Order.find_by(id: id)
      return nil unless order
      
      authorize!(order, :show)
      order
    end
    
    def product(id:)
      product = Product.find_by(id: id)
      return nil unless product
      
      authorize!(product, :show)
      product
    end
  end
end
