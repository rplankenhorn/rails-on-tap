class KegTap < ApplicationRecord
  # Associations
  belongs_to :current_keg, class_name: "Keg", optional: true
  belongs_to :temperature_sensor, class_name: "ThermoSensor", optional: true
  has_one :meter, class_name: "FlowMeter", dependent: :nullify
  has_one :flow_toggle, class_name: "FlowToggle", dependent: :nullify
  has_many :kegs, dependent: :nullify

  # Validations
  validates :name, presence: true, length: { maximum: 128 }
  validates :sort_order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Default scope
  default_scope -> { order(:sort_order, :id) }

  # Instance methods
  def active?
    current_keg.present?
  end

  def current_temperature
    return nil unless temperature_sensor
    temperature_sensor.thermologs.order(time: :desc).first
  end

  def attach_keg!(keg)
    raise "Tap is already active" if active?
    transaction do
      end_current_keg! if current_keg
      keg.update!(status: "on_tap", start_time: Time.current, keg_tap_id: id)
      update!(current_keg: keg)
    end
    keg
  end

  def end_current_keg!
    return unless current_keg
    transaction do
      keg = current_keg
      update!(current_keg: nil)
      keg.end_keg!
    end
  end
end
