class KegbotSite < ApplicationRecord
  # Constants
  VOLUME_UNITS = { "metric" => "Metric (mL, L)", "imperial" => "Imperial (oz, pint)" }.freeze
  TEMPERATURE_UNITS = { "f" => "Fahrenheit", "c" => "Celsius" }.freeze
  PRIVACY_CHOICES = {
    "public" => "Public: Browsing does not require login",
    "members" => "Members only: Must log in to browse",
    "staff" => "Staff only: Only logged-in staff accounts may browse"
  }.freeze
  REGISTRATION_MODES = {
    "public" => "Public: Anyone can register.",
    "member-invite-only" => "Member Invite: Must be invited by an existing member.",
    "staff-invite-only" => "Staff Invite Only: Must be invited by a staff member."
  }.freeze

  # Associations
  has_one_attached :background_image

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :volume_display_units, inclusion: { in: VOLUME_UNITS.keys }
  validates :temperature_display_units, inclusion: { in: TEMPERATURE_UNITS.keys }
  validates :privacy, inclusion: { in: PRIVACY_CHOICES.keys }
  validates :registration_mode, inclusion: { in: REGISTRATION_MODES.keys }
  validates :session_timeout_minutes, numericality: { only_integer: true, greater_than: 0 }

  # Callbacks
  before_validation :set_defaults, on: :create

  # Singleton pattern
  def self.get
    find_or_create_by(name: "default") do |site|
      site.title = "My Kegbot"
      site.is_setup = false
      site.volume_display_units = "imperial"
      site.temperature_display_units = "f"
      site.privacy = "public"
      site.registration_mode = "public"
      site.timezone = "UTC"
      site.session_timeout_minutes = 180
      site.enable_sensing = true
      site.enable_users = true
    end
  end

  def format_volume(volume_ml)
    if volume_display_units == "metric"
      volume_ml < 500 ? "#{volume_ml.to_i} mL" : "#{(volume_ml / 1000.0).round(1)} L"
    else
      "#{(volume_ml * 0.033814).round(1)} oz"
    end
  end

  def can_invite?(user)
    return false unless user
    return true if registration_mode == "public"
    return !user.new_record? if registration_mode == "member-invite-only"
    return user.is_staff if registration_mode == "staff-invite-only"
    false
  end

  private

  def set_defaults
    self.session_timeout_minutes ||= 180
    self.enable_sensing = true if enable_sensing.nil?
    self.enable_users = true if enable_users.nil?
  end
end
