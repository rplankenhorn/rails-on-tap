class HardwareController < ApplicationRecord
  # Associations
  has_many :meters, class_name: "FlowMeter", foreign_key: "controller_id", dependent: :destroy
  has_many :toggles, class_name: "FlowToggle", foreign_key: "controller_id", dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: true, length: { maximum: 128 }
  validates :controller_model_name, length: { maximum: 128 }
  validates :serial_number, length: { maximum: 128 }

  def to_s
    "Controller: #{name}"
  end
end
