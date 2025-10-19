class KegboardConfig < ApplicationRecord
  # Encrypt sensitive data (requires encryption keys to be configured)
  # To enable encryption, uncomment the line below and configure:
  # bin/rails db:encryption:init
  # encrypts :mqtt_password, deterministic: false

  # Constants
  CONFIG_TYPES = %w[mqtt serial usb].freeze

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :config_type, inclusion: { in: CONFIG_TYPES }
  validates :mqtt_broker, presence: true, if: -> { config_type == "mqtt" }
  validates :mqtt_port, numericality: { only_integer: true, greater_than: 0, less_than: 65536 }, allow_nil: true
  validates :mqtt_topic_prefix, presence: true, if: -> { config_type == "mqtt" }

  # Scopes
  scope :enabled, -> { where(enabled: true) }
  scope :mqtt, -> { where(config_type: "mqtt") }

  # Class methods
  def self.default
    enabled.first || first
  end

  # Instance methods
  def mqtt_url
    return nil unless config_type == "mqtt"

    url = "mqtt://"
    url += "#{mqtt_username}:#{mqtt_password}@" if mqtt_username.present?
    url += mqtt_broker
    url += ":#{mqtt_port}" if mqtt_port.present?
    url
  end

  def meter_topic(meter_id)
    "#{mqtt_topic_prefix}/meter/#{meter_id}"
  end

  def to_s
    "#{name} (#{config_type})"
  end
end
