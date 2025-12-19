class CreateInventoryAlerts < ActiveRecord::Migration[7.1]
  def change
    create_table :inventory_alerts, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.references :variant, null: false, foreign_key: true, type: :uuid
      t.references :location, null: false, foreign_key: true, type: :uuid
      t.integer :threshold, null: false
      t.integer :current_level, null: false
      t.boolean :reviewed, default: false
      t.references :reviewed_by, foreign_key: { to_table: :users }, type: :uuid
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :inventory_alerts, %i[store_id reviewed]
  end
end
