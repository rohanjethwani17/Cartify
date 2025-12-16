class Order < ApplicationRecord
  STATUSES = %w[pending confirmed fulfilled cancelled].freeze
  FULFILLMENT_STATUSES = %w[unfulfilled partial fulfilled].freeze
  FINANCIAL_STATUSES = %w[pending paid refunded].freeze
  
  # Associations
  belongs_to :store
  has_many :line_items, dependent: :destroy
  has_many :variants, through: :line_items
  has_many :fulfillments, dependent: :destroy
  has_many :audit_logs, as: :resource
  
  # Validations
  validates :order_number, presence: true, uniqueness: { scope: :store_id }
  validates :status, inclusion: { in: STATUSES }
  validates :fulfillment_status, inclusion: { in: FULFILLMENT_STATUSES }
  validates :financial_status, inclusion: { in: FINANCIAL_STATUSES }
  validates :idempotency_key, uniqueness: true, allow_nil: true
  
  # Callbacks
  before_validation :generate_order_number, on: :create
  
  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :unfulfilled, -> { where(fulfillment_status: 'unfulfilled') }
  scope :recent, -> { order(created_at: :desc) }
  scope :search, ->(query) {
    where('order_number ILIKE ? OR email ILIKE ?', "%#{query}%", "%#{query}%") if query.present?
  }
  
  # Age scopes for dashboard
  scope :aged_0_1_days, -> { where(created_at: 1.day.ago..) }
  scope :aged_2_3_days, -> { where(created_at: 3.days.ago..1.day.ago) }
  scope :aged_4_7_days, -> { where(created_at: 7.days.ago..3.days.ago) }
  scope :aged_8_plus_days, -> { where(created_at: ..7.days.ago) }
  
  def calculate_totals
    self.subtotal = line_items.sum { |li| li.price * li.quantity }
    self.total_price = subtotal + total_tax + total_shipping
  end
  
  def unfulfilled_items
    line_items.select { |li| li.quantity > li.fulfilled_quantity }
  end
  
  def fully_fulfilled?
    line_items.all? { |li| li.quantity == li.fulfilled_quantity }
  end
  
  private
  
  def generate_order_number
    return if order_number.present?
    
    prefix = store&.slug&.upcase&.first(3) || 'ORD'
    sequence = store&.orders&.count.to_i + 1
    self.order_number = "#{prefix}-#{sequence.to_s.rjust(6, '0')}"
  end
end
