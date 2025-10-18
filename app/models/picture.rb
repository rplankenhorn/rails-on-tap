class Picture < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  belongs_to :keg, optional: true
  belongs_to :drinking_session, optional: true
  belongs_to :drink, optional: true
  has_one_attached :image

  # Validations
  validates :time, presence: true

  # Instance methods
  def get_caption
    return caption if caption.present?
    return "#{user.username} pouring drink #{drink.id}" if drink && user
    return "An unknown drinker pouring drink #{drink.id}" if drink
    ""
  end
end
