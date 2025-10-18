class Beverage < ApplicationRecord
  # Constants
  TYPES = {
    beer: "Beer",
    wine: "Wine",
    soda: "Soda",
    kombucha: "Kombucha",
    other: "Other/Unknown"
  }.freeze

  # Associations
  belongs_to :beverage_producer
  has_many :kegs, dependent: :restrict_with_error
  has_one_attached :picture

  # Convenience methods
  def producer
    beverage_producer
  end

  def abv
    abv_percent
  end

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :beverage_type, inclusion: { in: TYPES.keys.map(&:to_s) }
  validates :style, length: { maximum: 255 }
  validates :color_hex, format: { with: /\A#[0-9a-fA-F]{3}([0-9a-fA-F]{3})?\z/, allow_blank: true }
  validates :abv_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :star_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true

  # Callbacks
  before_validation :set_default_color

  # Default scope
  default_scope -> { order(:name) }

  def full_name
    "#{name} by #{beverage_producer.name}"
  end

  private

  def set_default_color
    self.color_hex ||= "#FFCC00"
  end
end
