class CreateStoreMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :store_memberships, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :role, null: false, default: 'staff' # owner, staff, read_only
      
      t.timestamps
    end
    
    add_index :store_memberships, [:store_id, :user_id], unique: true
  end
end
