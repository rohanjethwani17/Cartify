class Store < ApplicationRecord
  # Associations
  has_many :store_memberships, dependent: :destroy
  has_many :users, through: :store_memberships
  has_many :products, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :audit_logs, dependent: :destroy
  has_many :inventory_alerts, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :low_stock_threshold, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :generate_slug, on: :create

  # Scopes
  scope :active, -> { where.not(id: nil) }

  def owner
    store_memberships.find_by(role: 'owner')&.user
  end

  def add_member(user, role: 'staff')
    store_memberships.create(user: user, role: role)
  end

  private

  def generate_slug
    return if slug.present?

    self.slug = name.parameterize if name.present?
  end
end
