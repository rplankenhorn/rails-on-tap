class SystemEvent < ApplicationRecord
  # Constants
  KINDS = {
    drink_poured: "Drink poured",
    session_started: "Session started",
    session_joined: "User joined session",
    keg_tapped: "Keg tapped",
    keg_volume_low: "Keg volume low",
    keg_ended: "Keg ended"
  }.freeze

  # Associations
  belongs_to :user, optional: true
  belongs_to :drink, optional: true
  belongs_to :keg, optional: true
  belongs_to :drinking_session, optional: true

  # Validations
  validates :kind, presence: true, inclusion: { in: KINDS.keys.map(&:to_s) }
  validates :time, presence: true

  # Default scope
  default_scope -> { order(id: :desc) }

  # Class methods
  def self.build_events_for_keg(keg)
    events = []

    if keg.on_tap? && !keg.events.exists?(kind: "keg_tapped")
      event = keg.events.create!(kind: "keg_tapped", time: keg.start_time)
      events << event
    end

    if keg.finished? && !keg.events.exists?(kind: "keg_ended")
      event = keg.events.create!(kind: "keg_ended", time: keg.end_time)
      events << event
    end

    events
  end

  def self.build_events_for_drink(drink)
    events = []
    keg = drink.keg
    session = drink.drinking_session
    user = drink.user

    # Keg events
    events.concat(build_events_for_keg(keg))

    # Session started event
    if session && !session.events.exists?(kind: "session_started")
      event = session.events.create!(
        kind: "session_started",
        time: session.start_time,
        drink: drink,
        user: user
      )
      events << event
    end

    # Session joined event
    if user && session && !user.events.exists?(kind: "session_joined", drinking_session: session)
      event = user.events.create!(
        kind: "session_joined",
        time: drink.time,
        drinking_session: session,
        drink: drink
      )
      events << event
    end

    # Drink poured event
    event = drink.events.create!(
      kind: "drink_poured",
      time: drink.time,
      user: user,
      keg: keg,
      drinking_session: session
    )
    events << event

    # Keg volume low event
    volume_now = keg.remaining_volume_ml
    volume_before = volume_now + drink.volume_ml
    threshold = keg.full_volume_ml * 0.15 # 15% threshold

    if volume_now <= threshold && volume_before > threshold
      event = drink.events.create!(
        kind: "keg_volume_low",
        time: drink.time,
        user: user,
        keg: keg,
        drinking_session: session
      )
      events << event
    end

    events
  end
end
