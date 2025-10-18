class BeverageProducer < ApplicationRecord
  # Associations
  has_many :beverages, dependent: :restrict_with_error
  has_one_attached :picture

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :country, length: { maximum: 128 }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, if: -> { url.present? }

  # Default scope
  default_scope -> { order(:name) }
end
