class LineItem < ApplicationRecord
  # Associations
  belongs_to :order
  belongs_to :variant
  has_one :product, through: :variant

  # Validations
  validates :title, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fulfilled_quantity, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :set_defaults_from_variant, on: :create

  def total
    (price * quantity) - total_discount
  end

  def remaining_to_fulfill
    quantity - fulfilled_quantity
  end

  def fully_fulfilled?
    fulfilled_quantity >= quantity
  end

  private

  def set_defaults_from_variant
    return unless variant.present?

    self.title ||= variant.product.title
    self.variant_title ||= variant.title
    self.sku ||= variant.sku
    self.price ||= variant.price
    self.requires_shipping = variant.requires_shipping if requires_shipping.nil?
  end
end
