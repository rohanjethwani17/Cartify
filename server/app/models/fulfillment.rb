class Fulfillment < ApplicationRecord
  STATUSES = %w[pending open success cancelled].freeze

  # Associations
  belongs_to :order
  belongs_to :location, optional: true

  # Validations
  validates :status, inclusion: { in: STATUSES }

  # Callbacks
  after_save :update_order_fulfillment_status

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :successful, -> { where(status: 'success') }

  def ship!(tracking_number: nil, tracking_company: nil, tracking_url: nil)
    update!(
      status: 'success',
      tracking_number: tracking_number,
      tracking_company: tracking_company,
      tracking_url: tracking_url,
      shipped_at: Time.current
    )
  end

  def cancel!
    update!(status: 'cancelled')
  end

  private

  def update_order_fulfillment_status
    return unless order.present?

    if order.fully_fulfilled?
      order.update!(fulfillment_status: 'fulfilled')
    elsif order.line_items.any? { |li| li.fulfilled_quantity.positive? }
      order.update!(fulfillment_status: 'partial')
    end
  end
end
