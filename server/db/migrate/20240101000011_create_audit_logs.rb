class CreateAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.references :store, null: false, foreign_key: true, type: :uuid
      t.references :user, foreign_key: true, type: :uuid
      t.string :action, null: false
      t.string :resource_type, null: false
      t.uuid :resource_id, null: false
      t.jsonb :changes, default: {}
      t.jsonb :metadata, default: {}
      t.inet :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :audit_logs, %i[store_id resource_type resource_id]
    add_index :audit_logs, %i[store_id action]
    add_index :audit_logs, :created_at
  end
end
