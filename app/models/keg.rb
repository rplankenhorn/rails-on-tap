class Keg < ApplicationRecord
  # Constants
  KEG_SIZES = {
    "half_barrel" => { description: "Half Barrel (15.5 gal)", volume_ml: 58674 },
    "quarter_barrel" => { description: "Quarter Barrel (7.75 gal)", volume_ml: 29337 },
    "sixth_barrel" => { description: "Sixth Barrel (5.17 gal)", volume_ml: 19570 },
    "cornelius" => { description: "Cornelius (5 gal)", volume_ml: 18927 },
    "euro" => { description: "Euro (50L)", volume_ml: 50000 },
    "other" => { description: "Other", volume_ml: 0 }
  }.freeze

  STATUSES = %w[available on_tap finished].freeze

  # Associations
  belongs_to :beverage
  belongs_to :keg_tap, optional: true
  has_one :current_tap, class_name: "KegTap", foreign_key: "current_keg_id", dependent: :nullify
  has_many :drinks, dependent: :restrict_with_error
  has_many :events, class_name: "SystemEvent", dependent: :destroy
  has_many :pictures, dependent: :nullify
  has_many :stats, dependent: :destroy

  # Validations
  validates :keg_type, inclusion: { in: KEG_SIZES.keys }
  validates :status, inclusion: { in: STATUSES }
  validates :served_volume_ml, numericality: { greater_than_or_equal_to: 0 }
  validates :spilled_ml, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :set_full_volume_from_type, on: :create
  before_save :adjust_times_from_drinks

  # Scopes
  scope :available, -> { where(status: "available") }
  scope :on_tap, -> { where(status: "on_tap") }
  scope :finished, -> { where(status: "finished") }

  # Instance methods
  def remaining_volume_ml
    full_volume_ml - served_volume_ml - spilled_ml
  end

  def percent_full
    return 0 if full_volume_ml.nil? || full_volume_ml <= 0
    result = (remaining_volume_ml.to_f / full_volume_ml * 100)
    [ [ result, 100 ].min, 0 ].max
  end

  def size_name
    KEG_SIZES.dig(keg_type, :description) || keg_type&.titleize || "Unknown"
  end

  def keg_age
    end_time = status == "on_tap" ? Time.current : self.end_time
    end_time - start_time
  end

  def empty?
    remaining_volume_ml <= 0
  end

  def available?
    status == "available"
  end

  def on_tap?
    status == "on_tap"
  end

  def finished?
    status == "finished"
  end

  def end_keg!
    update!(status: "finished", end_time: Time.current)
    SystemEvent.build_events_for_keg(self)
  end

  def self.create_keg(beverage:, keg_type: "half_barrel", **options)
    keg = new(
      beverage: beverage,
      keg_type: keg_type,
      served_volume_ml: 0,
      spilled_ml: 0,
      status: "available",
      start_time: Time.current,
      end_time: Time.current,
      **options
    )
    keg.save!
    keg
  end

  private

  def set_full_volume_from_type
    self.full_volume_ml ||= KEG_SIZES[keg_type][:volume_ml] if keg_type.present?
  end

  def adjust_times_from_drinks
    return if status == "on_tap"
    return if drinks.empty?

    first_drink = drinks.order(:time).first
    last_drink = drinks.order(:time).last

    self.start_time = first_drink.time if first_drink.time < start_time
    self.end_time = last_drink.time if last_drink.time > end_time
  end
end
