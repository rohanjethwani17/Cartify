class InventoryAlert < ApplicationRecord
  # Associations
  belongs_to :store
  belongs_to :variant
  belongs_to :location
  belongs_to :reviewed_by, class_name: 'User', optional: true
  
  # Validations
  validates :threshold, presence: true, numericality: { greater_than: 0 }
  validates :current_level, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Scopes
  scope :unreviewed, -> { where(reviewed: false) }
  scope :reviewed, -> { where(reviewed: true) }
  scope :recent, -> { order(created_at: :desc) }
  
  def mark_reviewed!(user)
    update!(
      reviewed: true,
      reviewed_by: user,
      reviewed_at: Time.current
    )
  end
  
  def self.create_for_low_stock(inventory_level, threshold)
    store = inventory_level.location.store
    
    create!(
      store: store,
      variant: inventory_level.variant,
      location: inventory_level.location,
      threshold: threshold,
      current_level: inventory_level.available
    )
  end
end
