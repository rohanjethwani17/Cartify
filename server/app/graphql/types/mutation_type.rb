module Types
  class MutationType < Types::BaseObject
    # Authentication
    field :sign_in, mutation: Mutations::SignIn
    field :sign_out, mutation: Mutations::SignOut

    # Products
    field :create_product, mutation: Mutations::CreateProduct
    field :update_product, mutation: Mutations::UpdateProduct

    # Orders
    field :create_order, mutation: Mutations::CreateOrder
    field :update_fulfillment_status, mutation: Mutations::UpdateFulfillmentStatus

    # Inventory
    field :adjust_inventory, mutation: Mutations::AdjustInventory
    field :mark_inventory_alert_reviewed, mutation: Mutations::MarkInventoryAlertReviewed

    # Store settings
    field :update_store_settings, mutation: Mutations::UpdateStoreSettings

    # Demo data
    field :generate_demo_data, mutation: Mutations::GenerateDemoData
  end
end
