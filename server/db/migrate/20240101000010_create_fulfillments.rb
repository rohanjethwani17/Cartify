class CreateFulfillments < ActiveRecord::Migration[7.1]
  def change
    create_table :fulfillments, id: :uuid do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.references :location, foreign_key: true, type: :uuid
      t.string :status, default: 'pending' # pending, open, success, cancelled
      t.string :tracking_company
      t.string :tracking_number
      t.string :tracking_url
      t.datetime :shipped_at

      t.timestamps
    end
  end
end
