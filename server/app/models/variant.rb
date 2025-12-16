class Variant < ApplicationRecord
  # Associations
  belongs_to :product
  has_one :store, through: :product
  has_many :inventory_levels, dependent: :destroy
  has_many :locations, through: :inventory_levels
  has_many :line_items, dependent: :restrict_with_error
  has_many :inventory_alerts, dependent: :destroy
  
  # Validations
  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, uniqueness: { scope: :product_id }, allow_blank: true
  
  # Scopes
  scope :in_stock, -> { joins(:inventory_levels).where('inventory_levels.available > 0') }
  scope :low_stock, ->(threshold) {
    joins(:inventory_levels)
      .group('variants.id')
      .having('SUM(inventory_levels.available) <= ?', threshold)
  }
  
  def total_available
    inventory_levels.sum(:available)
  end
  
  def available_at(location)
    inventory_levels.find_by(location: location)&.available || 0
  end
  
  def display_name
    "#{product.title} - #{title}"
  end
end
