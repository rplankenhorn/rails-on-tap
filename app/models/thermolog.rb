class Thermolog < ApplicationRecord
  # Associations
  belongs_to :thermo_sensor

  # Validations
  validates :temp, presence: true, numericality: true
  validates :time, presence: true

  # Default scope
  default_scope -> { order(time: :desc) }

  def temp_c
    temp
  end

  def temp_f
    (temp * 9.0 / 5.0) + 32
  end
end
