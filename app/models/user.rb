class User < ApplicationRecord
  has_secure_password
  before_validation :normalize_fields

  has_many :food_places, dependent: :destroy
  has_many :blogs, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_food_places, through: :favorites, source: :food_place
  has_many :reviews, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :video_tutorials, dependent: :destroy

  has_one_attached :avatar, dependent: :destroy

  # User validation
  validates :name, presence: { message: I18n.t("activerecord.errors.models.user.attributes.name.blank") }
  validates :last_name, presence: { message: I18n.t("activerecord.errors.models.user.attributes.last_name.blank") }

  validates :email,
            format: {
              with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
              message: I18n.t("activerecord.errors.models.user.attributes.email.invalid")
            },
            uniqueness: { case_sensitive: false, message: I18n.t("activerecord.errors.models.user.attributes.email.taken") }

  validates :password,
            presence: { message: I18n.t("activerecord.errors.models.user.attributes.password.blank") },
            length: { minimum: 10, allow_nil: true, message: I18n.t("activerecord.errors.models.user.attributes.password.too_short") },
            if: :password_required?

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

  def generate_password_reset_token!
    raw_token = SecureRandom.urlsafe_base64(32)

    update!(
      password_reset_token: raw_token,
      password_reset_sent_at: Time.current,
    )

    signed_token_for(raw_token)
  end

  def clear_password_reset_token!
    update!(password_reset_token: nil, password_reset_sent_at: nil)
  end

  def password_reset_token_valid?(expiry = 10.minutes)
    return false if password_reset_sent_at.nil?
    password_reset_sent_at > Time.current - expiry
  end

  def generate_confirmation_token!
    raw_token = SecureRandom.urlsafe_base64(32)

    update!(
      confirmation_token: raw_token,
      confirmation_sent_at: Time.current

    )
    raw_token
  end

  def confirmation_token_valid?(expiry = 15.minutes)
    return false if confirmation_sent_at.nil?
    confirmation_sent_at > Time.current - expiry
  end

  scope :admin, -> { where(is_admin: true) }
  scope :moderator, -> { where(moderator: true) }
  scope :owner, -> { where(business_owner: true) }
  scope :user, -> { where(is_admin: false, moderator: false, business_owner: false) }
  scope :blocked, -> { where(is_blocked: true) }
  scope :active, -> { where(is_blocked: false) }

  scope :search, ->(search_term) {
    if search_term.present?
      term = "%#{search_term.strip.downcase}%"
      where("LOWER(name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(email) LIKE ?", term, term, term)
    else
      all
    end
  }

  private

  def password_required?
    new_record? || password.present?
  end

  def acceptable_image
    return unless avatar.attached?

    unless avatar.byte_size <= 8.megabyte
      errors.add(:avatar, I18n.t("activerecord.errors.models.user.attributes.avatar.too_large"))
    end

    acceptable_types = %w[image/png image/jpg image/jpeg]
    unless acceptable_types.include? avatar.content_type
      errors.add(:avatar, I18n.t("activerecord.errors.models.user.attributes.avatar.invalid_format"))
    end
  end

  def normalize_fields
    self.email = email&.downcase&.strip if email.present?
    self.name = name&.strip&.capitalize if name.present?
    self.last_name = last_name&.strip&.capitalize if last_name.present?
  end

  def signed_token_for(raw_token)
    verifier.generate(raw_token)
  end

  def verifier
    ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base, digest: "SHA256")
  end
end
