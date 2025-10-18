class ThermoSensor < ApplicationRecord
  # Associations
  has_many :thermologs, dependent: :destroy
  has_many :keg_taps, foreign_key: "temperature_sensor_id", dependent: :nullify

  # Validations
  validates :raw_name, presence: true, length: { maximum: 256 }
  validates :nice_name, length: { maximum: 128 }

  def display_name
    nice_name.presence || raw_name
  end

  def last_log
    thermologs.order(time: :desc).first
  end

  def log_sensor_reading(temperature, at_time: nil)
    at_time ||= Time.current
    at_time = at_time.change(sec: 0) # Round to minute

    # Validate temperature range (-40C to 80C)
    raise ArgumentError, "Temperature out of bounds" unless temperature.between?(-40, 80)

    log = thermologs.find_or_initialize_by(time: at_time)
    log.temp = temperature
    log.save!

    # Clean up old entries (keep last 24 hours)
    thermologs.where("time < ?", 24.hours.ago).delete_all

    log
  end
end
