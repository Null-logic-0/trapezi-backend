class User < ApplicationRecord
  has_secure_password
  before_validation :normalize_fields

  has_many :food_places, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_food_places, through: :favorites, source: :food_place

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
end
