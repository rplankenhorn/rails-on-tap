class AuthenticationToken < ApplicationRecord
  # Constants
  AUTH_DEVICE_RFID = "core.rfid"
  AUTH_DEVICE_ONEWIRE = "core.onewire"

  # Associations
  belongs_to :user, optional: true

  # Validations
  validates :auth_device, presence: true, length: { maximum: 64 }
  validates :token_value, presence: true, length: { maximum: 128 }
  validates :token_value, uniqueness: { scope: :auth_device }
  validates :nice_name, length: { maximum: 256 }
  validates :pin, length: { maximum: 256 }

  # Callbacks
  before_validation :normalize_hex_values

  # Instance methods
  def assigned?
    user.present?
  end

  def active?
    return false unless enabled
    return true if expire_time.nil?
    Time.current < expire_time
  end

  def auth_device_name
    case auth_device
    when AUTH_DEVICE_RFID
      "RFID"
    when AUTH_DEVICE_ONEWIRE
      "OneWire"
    else
      auth_device
    end
  end

  def to_s
    name = "#{auth_device_name} #{token_value}"
    name += " (#{nice_name})" if nice_name.present?
    name
  end

  def self.create_auth_token(auth_device:, token_value:, username: nil, **options)
    token = create!(auth_device: auth_device, token_value: token_value, **options)
    if username
      user = User.find_by(username: username)
      token.update(user: user) if user
    end
    token
  end

  private

  def normalize_hex_values
    if [ AUTH_DEVICE_RFID, AUTH_DEVICE_ONEWIRE ].include?(auth_device)
      self.token_value = token_value.downcase if token_value
    end
  end
end
