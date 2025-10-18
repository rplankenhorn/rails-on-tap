class Device < ApplicationRecord
  # Associations
  has_many :api_keys, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 255 }

  # Callbacks
  before_validation :set_created_time, on: :create

  private

  def set_created_time
    self.created_time ||= Time.current
  end
end
