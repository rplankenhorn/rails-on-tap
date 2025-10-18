class ApiKey < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  belongs_to :device, optional: true

  # Validations
  validates :key, presence: true, uniqueness: true, length: { maximum: 127 }
  validates :description, length: { maximum: 1000 }

  # Callbacks
  before_validation :generate_key_if_blank, on: :create

  # Instance methods
  def active?
    active && (!user || user.is_active)
  end

  def regenerate!
    update!(key: self.class.generate_key)
  end

  # Class methods
  def self.generate_key
    SecureRandom.hex(64)
  end

  private

  def generate_key_if_blank
    self.key = self.class.generate_key if key.blank?
  end
end
