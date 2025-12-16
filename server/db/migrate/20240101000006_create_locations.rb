class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :address1
      t.string :address2
      t.string :city
      t.string :province
      t.string :country, default: 'US'
      t.string :zip
      t.boolean :active, default: true
      
      t.timestamps
    end
  end
end
