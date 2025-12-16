class StoreMembership < ApplicationRecord
  ROLES = %w[owner staff read_only].freeze
  
  # Associations
  belongs_to :store
  belongs_to :user
  
  # Validations
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :store_id }
  
  # Scopes
  scope :owners, -> { where(role: 'owner') }
  scope :staff, -> { where(role: %w[owner staff]) }
  
  def can_write?
    %w[owner staff].include?(role)
  end
  
  def can_manage?
    role == 'owner'
  end
end
