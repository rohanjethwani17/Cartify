class Location < ApplicationRecord
  # Associations
  belongs_to :store
  has_many :inventory_levels, dependent: :destroy
  has_many :variants, through: :inventory_levels
  has_many :fulfillments
  has_many :inventory_alerts, dependent: :destroy

  # Validations
  validates :name, presence: true

  # Scopes
  scope :active, -> { where(active: true) }

  def full_address
    [address1, address2, city, province, zip, country].compact.join(', ')
  end
end
