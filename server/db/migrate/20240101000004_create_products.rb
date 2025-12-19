class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.string :title, null: false
      t.text :description
      t.string :status, default: 'draft' # draft, active, archived
      t.string :product_type
      t.string :vendor
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :products, %i[store_id status]
    add_index :products, %i[store_id title]
  end
end
