class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :store_memberships, dependent: :destroy
  has_many :stores, through: :store_memberships
  has_many :audit_logs

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  # Scopes
  scope :active, -> { where.not(id: nil) }

  def role_for_store(store)
    store_memberships.find_by(store: store)&.role
  end

  def owner_of?(store)
    role_for_store(store) == 'owner'
  end

  def staff_of?(store)
    %w[owner staff].include?(role_for_store(store))
  end

  def member_of?(store)
    store_memberships.exists?(store: store)
  end

  def generate_jwt
    payload = {
      user_id: id,
      email: email,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.credentials.secret_key_base || ENV.fetch('SECRET_KEY_BASE', nil))
  end

  def self.from_jwt(token)
    payload = JWT.decode(
      token,
      Rails.application.credentials.secret_key_base || ENV.fetch('SECRET_KEY_BASE', nil),
      true,
      algorithm: 'HS256'
    ).first
    find_by(id: payload['user_id'])
  rescue JWT::DecodeError
    nil
  end
end
