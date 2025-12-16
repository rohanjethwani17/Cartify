class AuditLog < ApplicationRecord
  # Associations
  belongs_to :store
  belongs_to :user, optional: true
  
  # Validations
  validates :action, presence: true
  validates :resource_type, presence: true
  validates :resource_id, presence: true
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_resource, ->(type, id) { where(resource_type: type, resource_id: id) }
  scope :by_user, ->(user) { where(user: user) }
  scope :by_action, ->(action) { where(action: action) }
  
  # Class method to create audit log
  def self.log(store:, user:, action:, resource:, changes: {}, metadata: {}, request: nil)
    create!(
      store: store,
      user: user,
      action: action,
      resource_type: resource.class.name,
      resource_id: resource.id,
      changes: changes,
      metadata: metadata,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end
end
