class DrinkingSession < ApplicationRecord
  # Associations
  has_many :drinks, dependent: :nullify
  has_many :events, class_name: "SystemEvent", dependent: :destroy
  has_many :pictures, dependent: :nullify
  has_many :stats, dependent: :destroy

  # Validations
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :volume_ml, numericality: { greater_than_or_equal_to: 0 }

  # Default scope
  default_scope -> { order(start_time: :desc) }

  # Instance methods
  def duration
    end_time - start_time
  end

  def active?(at_time = Time.current)
    end_time > at_time
  end

  def title
    name.presence || "Session ##{id}"
  end

  def add_drink(drink)
    timeout = KegbotSite.get.session_timeout_minutes.minutes
    session_end = drink.time + timeout

    self.start_time = drink.time if start_time > drink.time
    self.end_time = session_end if end_time < session_end
    self.volume_ml += drink.volume_ml
    save!
  end

  def rebuild!
    return destroy if drinks.empty?

    transaction do
      self.volume_ml = 0
      timeout = KegbotSite.get.session_timeout_minutes.minutes

      first_drink = drinks.order(:time).first
      last_drink = drinks.order(:time).last

      self.start_time = first_drink.time
      self.end_time = last_drink.time + timeout

      drinks.each { |d| self.volume_ml += d.volume_ml }
      save!
    end
  end

  def summarize_drinkers
    user_ids = drinks.where.not(user_id: nil).pluck(:user_id).uniq
    users = User.where(id: user_ids).pluck(:username)

    return "no known drinkers" if users.empty?

    guest_present = users.include?("guest")
    users.delete("guest")
    trailer = guest_present ? " (and possibly others)" : ""

    case users.length
    when 0
      "guest#{trailer}"
    when 1
      "#{users[0]}#{trailer}"
    when 2
      "#{users.join(' and ')}#{trailer}"
    else
      "#{users[0]}, #{users[1]} and #{users.length - 2} others#{trailer}"
    end
  end

  def self.assign_session_for_drink(drink)
    return drink.drinking_session if drink.drinking_session

    last_session = order(end_time: :desc).first
    if last_session&.active?(drink.time)
      last_session.add_drink(drink)
      drink.update(drinking_session: last_session)
      return last_session
    end

    # Create new session
    timeout = KegbotSite.get.session_timeout_minutes.minutes
    session = create!(
      start_time: drink.time,
      end_time: drink.time + timeout,
      volume_ml: 0,
      timezone: KegbotSite.get.timezone
    )
    session.add_drink(drink)
    drink.update(drinking_session: session)
    session
  end
end
