class CreateInventoryLevels < ActiveRecord::Migration[7.1]
  def change
    create_table :inventory_levels, id: :uuid do |t|
      t.references :variant, null: false, foreign_key: true, type: :uuid
      t.references :location, null: false, foreign_key: true, type: :uuid
      t.integer :available, default: 0, null: false
      t.integer :committed, default: 0, null: false
      t.integer :incoming, default: 0, null: false

      t.timestamps
    end

    add_index :inventory_levels, %i[variant_id location_id], unique: true
    add_index :inventory_levels, :available
  end
end
