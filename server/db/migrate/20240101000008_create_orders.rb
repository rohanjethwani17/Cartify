class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.string :order_number, null: false
      t.string :email
      t.string :status, default: 'pending' # pending, confirmed, fulfilled, cancelled
      t.string :fulfillment_status, default: 'unfulfilled' # unfulfilled, partial, fulfilled
      t.string :financial_status, default: 'pending' # pending, paid, refunded
      t.decimal :subtotal, precision: 10, scale: 2, default: 0
      t.decimal :total_tax, precision: 10, scale: 2, default: 0
      t.decimal :total_shipping, precision: 10, scale: 2, default: 0
      t.decimal :total_price, precision: 10, scale: 2, default: 0
      t.string :currency, default: 'USD'
      t.jsonb :shipping_address, default: {}
      t.jsonb :billing_address, default: {}
      t.string :idempotency_key, index: { unique: true }
      t.text :note

      t.timestamps
    end

    add_index :orders, %i[store_id order_number], unique: true
    add_index :orders, %i[store_id status]
    add_index :orders, %i[store_id fulfillment_status]
    add_index :orders, :created_at
  end
end
