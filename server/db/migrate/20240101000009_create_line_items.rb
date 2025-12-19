class CreateLineItems < ActiveRecord::Migration[7.1]
  def change
    create_table :line_items, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :variant, null: false, foreign_key: true, type: :uuid
      t.string :title, null: false
      t.string :variant_title
      t.string :sku
      t.integer :quantity, null: false, default: 1
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :total_discount, precision: 10, scale: 2, default: 0
      t.boolean :requires_shipping, default: true
      t.integer :fulfilled_quantity, default: 0

      t.timestamps
    end
  end
end
