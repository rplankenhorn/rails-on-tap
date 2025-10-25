class Drink < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :keg
  belongs_to :drinking_session, optional: true
  has_many :events, class_name: "SystemEvent", dependent: :destroy
  has_many :stats, dependent: :destroy
  has_many :pictures, dependent: :nullify

  # Validations
  validates :ticks, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :volume_ml, presence: true, numericality: { greater_than: 0 }
  validates :time, presence: true
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Callbacks
  after_create :assign_to_session
  after_create :update_keg_volume
  after_create :create_system_events

  # Default scope
  default_scope -> { order(time: :desc) }

  # Instance methods
  def guest_pour?
    user.nil? || user.guest?
  end

  def volume_oz
    volume_ml * 0.033814
  end

  def calories
    return 0 unless keg&.beverage&.calories_per_ml
    volume_ml * keg.beverage.calories_per_ml
  end

  def reassign!(new_user)
    return false if user == new_user

    transaction do
      update!(user: new_user)
      events.update_all(user_id: new_user.id)
      picture&.update(user: new_user)
      drinking_session&.rebuild!
    end
    true
  end

  def set_volume!(new_volume_ml)
    return if new_volume_ml == volume_ml

    transaction do
      difference = new_volume_ml - volume_ml
      update!(volume_ml: new_volume_ml)
      keg.increment!(:served_volume_ml, difference)
      drinking_session&.rebuild!
    end
  end

  def cancel!(spilled: false)
    transaction do
      session = drinking_session
      keg_record = keg
      volume = volume_ml

      keg_record.decrement!(:served_volume_ml, volume)
      keg_record.increment!(:spilled_ml, volume) if spilled

      destroy!
      session&.rebuild!
    end
  end

  def self.record_drink(tap_or_meter_name:, ticks:, volume_ml: nil, username: nil, pour_time: nil, duration: 0, shout: "", spilled: false, **options)
    tap = tap_or_meter_name.is_a?(KegTap) ? tap_or_meter_name : KegTap.joins(:meter).find_by(flow_meters: { port_name: tap_or_meter_name.split(".").last })
    raise "No active keg at this tap" unless tap&.active?

    keg = tap.current_keg

    if spilled
      keg.increment!(:spilled_ml, volume_ml)
      return nil
    end

    volume_ml ||= ticks.to_f / tap.meter.ticks_per_ml
    user = username ? User.find_by(username: username) : User.find_by(username: "guest")
    pour_time ||= Time.current

    create!(
      ticks: ticks,
      volume_ml: volume_ml,
      time: pour_time,
      duration: duration,
      shout: shout,
      user: user,
      keg: keg,
      **options
    )
  end

  private

  def assign_to_session
    DrinkingSession.assign_session_for_drink(self)
  end

  def update_keg_volume
    keg.increment!(:served_volume_ml, volume_ml)
  end

  def create_system_events
    SystemEvent.build_events_for_drink(self)
  end
end
