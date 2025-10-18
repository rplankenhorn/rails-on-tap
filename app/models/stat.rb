class Stat < ApplicationRecord
  # Associations
  belongs_to :drink
  belongs_to :user, optional: true
  belongs_to :keg, optional: true
  belongs_to :drinking_session, optional: true

  # Validations
  validates :time, presence: true
  validates :drink_id, uniqueness: { scope: [ :user_id, :keg_id, :drinking_session_id ] }

  # Class methods
  def self.get_latest_for_view(user: nil, keg: nil, session: nil)
    stat = where(user: user, keg: keg, drinking_session: session)
           .order(id: :desc)
           .first
    return {} unless stat

    stat.stats || {}
  end
end
