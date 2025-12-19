class InventoryLevel < ApplicationRecord
  # Associations
  belongs_to :variant
  belongs_to :location
  has_one :store, through: :location

  # Validations
  validates :available, numericality: { greater_than_or_equal_to: 0 }
  validates :committed, numericality: { greater_than_or_equal_to: 0 }
  validates :incoming, numericality: { greater_than_or_equal_to: 0 }
  validates :variant_id, uniqueness: { scope: :location_id }

  # Scopes
  scope :low_stock, ->(threshold) { where('available <= ?', threshold) }
  scope :in_stock, -> { where('available > 0') }
  scope :out_of_stock, -> { where(available: 0) }

  def adjust(delta, reason: nil)
    new_available = available + delta
    raise ArgumentError, 'Cannot have negative inventory' if new_available.negative?

    update!(available: new_available)
  end

  def reserve(quantity)
    raise ArgumentError, 'Not enough inventory' if available < quantity

    update!(
      available: available - quantity,
      committed: committed + quantity
    )
  end

  def fulfill(quantity)
    raise ArgumentError, 'Not enough committed inventory' if committed < quantity

    update!(committed: committed - quantity)
  end
end
