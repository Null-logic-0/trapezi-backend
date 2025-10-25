class User < ApplicationRecord
  has_secure_password

  before_validation :normalize_fields

  # User validation
  validates :name, presence: true
  validates :last_name, presence: true
  validates :email, format: {
    with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
    message: "must be a valid email" },
            uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 10, allow_nil: true }

  private

  def normalize_fields
    self.email = email&.downcase&.strip if email.present?
    self.name = name&.strip&.capitalize if name.present?
    self.last_name = last_name&.strip&.capitalize if last_name.present?
  end
end
