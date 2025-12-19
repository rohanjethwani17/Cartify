module Products
  class UpdateProduct < ApplicationService
    def initialize(product:, attributes: {}, current_user: nil)
      super()
      @product = product
      @attributes = attributes
      @current_user = current_user
    end

    def call
      ActiveRecord::Base.transaction do
        changes = {}

        # Track changes
        @attributes.each do |key, value|
          changes[key] = [@product.send(key), value] if @product.respond_to?(key) && @product.send(key) != value
        end

        @product.update!(@attributes.slice(:title, :description, :status, :product_type, :vendor))

        # Create audit log
        AuditLog.log(
          store: @product.store,
          user: @current_user,
          action: 'update',
          resource: @product,
          changes: changes
        )

        success(@product)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end
  end
end
