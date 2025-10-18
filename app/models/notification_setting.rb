class NotificationSetting < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :backend, presence: true, length: { maximum: 255 }
  validates :backend, uniqueness: { scope: :user_id }

  # Callbacks
  before_validation :set_defaults, on: :create

  private

  def set_defaults
    self.keg_tapped = true if keg_tapped.nil?
    self.session_started = false if session_started.nil?
    self.keg_volume_low = false if keg_volume_low.nil?
    self.keg_ended = false if keg_ended.nil?
  end
end
