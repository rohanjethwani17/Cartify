class CreateVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :variants, id: :uuid do |t|
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.string :title, null: false
      t.string :sku, index: true
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.decimal :compare_at_price, precision: 10, scale: 2
      t.integer :position, default: 0
      t.jsonb :option_values, default: {}
      t.boolean :requires_shipping, default: true
      t.decimal :weight, precision: 10, scale: 2
      t.string :weight_unit, default: 'kg'
      
      t.timestamps
    end
  end
end
