class Blog < ApplicationRecord
  belongs_to :user
  has_one_attached :image, dependent: :destroy

  validates :title, presence: { message: I18n.t("activerecord.errors.models.blog.title.blank") }
  validates :content,
            length: {
              maximum: 500,
              allow_nil: true,
              message: I18n.t("activerecord.errors.models.blog.content.too_long") },
            presence: { message: I18n.t("activerecord.errors.models.blog.content.blank") }

  validate :acceptable_image

  def image_url
    return unless image.attached?
    Rails.application.routes.url_helpers.url_for(image)
  end

  def as_json(options = {})
    super({
            methods: [ :image_url ],
            except: [ :password_digest ]
          }.merge(options))
  end

  private

  def acceptable_image
    return if Rails.env.test?
    unless image.attached?
      errors.add(:image, I18n.t(
        "activerecord.errors.models.blog.image.blank")
      )
      return
    end

    unless image.byte_size <= 12.megabyte
      errors.add(:image, I18n.t("activerecord.errors.models.blog.image.too_large"))
    end

    acceptable_types = %w[image/png image/jpg image/jpeg]
    unless acceptable_types.include? image.content_type
      errors.add(:image, I18n.t("activerecord.errors.models.blog.image.invalid_format"))
    end
  end
end
