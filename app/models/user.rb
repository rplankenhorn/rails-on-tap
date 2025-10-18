class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :api

  # Associations
  has_many :drinks, dependent: :nullify
  has_many :tokens, class_name: "AuthenticationToken", dependent: :destroy
  has_many :events, class_name: "SystemEvent", dependent: :nullify
  has_many :pictures, dependent: :nullify
  has_many :stats, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :notification_settings, dependent: :destroy
  has_many :invited_users, class_name: "Invitation", foreign_key: "invited_by_id", dependent: :nullify
  has_one_attached :mugshot_image

  # Validations
  validates :username, presence: true, uniqueness: true, length: { maximum: 30 }
  validates :username, format: { with: /\A[a-zA-Z0-9@.+_-]+\z/, message: "only allows letters, numbers and @/./+/-/_ characters" }
  validates :display_name, length: { maximum: 127 }

  # Callbacks
  before_validation :set_display_name_default

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :staff, -> { where(is_staff: true) }

  # Instance methods
  def guest?
    username == "guest"
  end

  def full_name
    display_name.presence || username
  end

  def short_name
    username
  end

  def get_or_create_api_key
    api_key = api_keys.first_or_create do |key|
      key.key = ApiKey.generate_key
      key.active = true
    end
    api_key.key
  end

  private

  def set_display_name_default
    self.display_name = username if display_name.blank?
  end
end
