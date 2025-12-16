module Products
  class CreateProduct < ApplicationService
    def initialize(store:, title:, attributes: {}, variants: [], current_user: nil)
      super()
      @store = store
      @title = title
      @attributes = attributes
      @variants_data = variants
      @current_user = current_user
    end
    
    def call
      ActiveRecord::Base.transaction do
        @product = @store.products.create!(
          title: @title,
          description: @attributes[:description],
          status: @attributes[:status] || 'draft',
          product_type: @attributes[:product_type],
          vendor: @attributes[:vendor]
        )
        
        # Create variants if provided
        if @variants_data.any?
          @product.variants.destroy_all # Remove default variant
          
          @variants_data.each_with_index do |variant_data, index|
            @product.variants.create!(
              title: variant_data[:title] || 'Default',
              sku: variant_data[:sku],
              price: variant_data[:price] || 0,
              compare_at_price: variant_data[:compare_at_price],
              position: index
            )
          end
        end
        
        # Create audit log
        AuditLog.log(
          store: @store,
          user: @current_user,
          action: 'create',
          resource: @product,
          changes: { title: [nil, @title], status: [nil, @product.status] }
        )
        
        success(@product)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end
  end
end
