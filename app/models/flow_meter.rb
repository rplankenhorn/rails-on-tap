class FlowMeter < ApplicationRecord
  # Constants
  DEFAULT_TICKS_PER_ML = 2.2

  # Associations
  belongs_to :controller, class_name: "HardwareController"
  belongs_to :keg_tap, optional: true

  # Validations
  validates :port_name, presence: true, length: { maximum: 128 }
  validates :ticks_per_ml, numericality: { greater_than: 0 }
  validates :port_name, uniqueness: { scope: :controller_id }

  # Callbacks
  before_validation :set_default_ticks_per_ml

  def meter_name
    "#{controller.name}.#{port_name}"
  end

  def self.get_or_create_from_meter_name(meter_name)
    controller_name, port = meter_name.split(".", 2)
    raise ArgumentError, "Invalid meter name" if port.blank?

    controller = HardwareController.find_or_create_by(name: controller_name)
    find_or_create_by(controller: controller, port_name: port)
  end

  private

  def set_default_ticks_per_ml
    self.ticks_per_ml ||= DEFAULT_TICKS_PER_ML
  end
end
