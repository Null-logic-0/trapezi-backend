class User < ApplicationRecord
  has_secure_password

  has_many :food_places, dependent: :destroy
  has_many :blogs, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_food_places, through: :favorites, source: :food_place
  has_many :reviews, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :video_tutorials, dependent: :destroy

  has_one_attached :avatar, dependent: :destroy

  include AttachmentUrl
  include ImageValidator
  include User::UserStatus
  include User::TokenGenerator
  include User::UserSanitizable
  include User::Scopes

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
            length: { minimum: 10, message: I18n.t("activerecord.errors.models.user.attributes.password.too_short") },
            if: -> { password.present? || password_required? }

  validate -> { validate_image(avatar) }

  def avatar_url
    file_url(avatar)
  end

  def as_json(options = {})
    super({
            methods: [ :avatar_url ],
            except: [ :password_digest ]
          }.merge(options || {}))
  end
end
