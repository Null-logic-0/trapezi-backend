class User < ApplicationRecord
  has_secure_password
  before_validation :normalize_fields

  has_one_attached :avatar, dependent: :destroy

  # User validation
  validates :name, presence: true
  validates :last_name, presence: true
  validates :email, format: {
    with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
    message: "must be a valid email" },
            uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 10, allow_nil: true }

  validate :acceptable_image

  def avatar_url
    return unless avatar.attached?
    Rails.application.routes.url_helpers.url_for(avatar)
  end

  def as_json(options = {})
    super({
            methods: [ :avatar_url ],
            except: [ :password_digest ]
          }.merge(options || {}))
  end

  private

  def acceptable_image
    return unless avatar.attached?

    unless avatar.byte_size <= 8.megabyte
      errors.add(:avatar, "must be less than 8MB")
    end

    acceptable_types = %w[image/png image/jpg image/jpeg]
    unless acceptable_types.include? avatar.content_type
      errors.add(:avatar, "must be a png, jpg, or jpeg format!")
    end
  end

  def normalize_fields
    self.email = email&.downcase&.strip if email.present?
    self.name = name&.strip&.capitalize if name.present?
    self.last_name = last_name&.strip&.capitalize if last_name.present?
  end
end
