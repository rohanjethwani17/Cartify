class Product < ApplicationRecord
  STATUSES = %w[draft active archived].freeze

  # Associations
  belongs_to :store
  has_many :variants, dependent: :destroy
  has_many :inventory_levels, through: :variants

  # Validations
  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :search, ->(query) { where('title ILIKE ?', "%#{query}%") if query.present? }

  # Callbacks
  after_create :create_default_variant

  def total_inventory
    variants.joins(:inventory_levels).sum('inventory_levels.available')
  end

  private

  def create_default_variant
    variants.create!(title: 'Default', price: 0) if variants.empty?
  end
end
