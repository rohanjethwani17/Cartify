class CreateStores < ActiveRecord::Migration[7.1]
  def change
    create_table :stores, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.integer :low_stock_threshold, default: 10
      t.jsonb :settings, default: {}
      
      t.timestamps
    end
  end
end
