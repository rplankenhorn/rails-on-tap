class Invitation < ApplicationRecord
  # Associations
  belongs_to :invited_by, class_name: "User", optional: true

  # Validations
  validates :invite_code, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :for_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Callbacks
  before_validation :generate_invite_code, on: :create
  before_validation :set_expires_date, on: :create
  before_validation :set_invited_date, on: :create

  def expired?(at_time = Time.current)
    at_time > expires_date
  end

  def send_invitation
    # TODO: Implement email sending
    # InvitationMailer.invite(self).deliver_later
  end

  private

  def generate_invite_code
    self.invite_code ||= SecureRandom.uuid
  end

  def set_expires_date
    self.expires_date ||= 24.hours.from_now
  end

  def set_invited_date
    self.invited_date ||= Time.current
  end
end
