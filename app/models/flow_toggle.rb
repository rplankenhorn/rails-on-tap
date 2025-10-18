class FlowToggle < ApplicationRecord
  # Associations
  belongs_to :controller, class_name: "HardwareController"
  belongs_to :keg_tap, optional: true

  # Validations
  validates :port_name, presence: true, length: { maximum: 128 }
  validates :port_name, uniqueness: { scope: :controller_id }

  def toggle_name
    "#{controller.name}.#{port_name}"
  end

  def self.get_or_create_from_toggle_name(toggle_name)
    controller_name, port = toggle_name.split(".", 2)
    raise ArgumentError, "Invalid toggle name" if port.blank?

    controller = HardwareController.find_or_create_by(name: controller_name)
    find_or_create_by(controller: controller, port_name: port)
  end
end
