class Blog < ApplicationRecord
  belongs_to :user
  has_one_attached :image, dependent: :destroy

  include ImageValidator
  include AttachmentUrl
  include Blog::Scopes
  include Blog::BlogSanitizable

  validates :title,
            presence: { message: I18n.t("activerecord.errors.models.blog.title.blank") },
            length: { maximum: 50, message: I18n.t("activerecord.errors.models.blog.title.too_long") }

  validates :content,
            presence: { message: I18n.t("activerecord.errors.models.blog.content.blank") },
            length: {
              maximum: 5000,
              message: I18n.t("activerecord.errors.models.blog.content.too_long") }

  validate -> { validate_image(image) }

  def image_url
    file_url(image)
  end

  def as_json(options = {})
    super({
            methods: [ :image_url, :formatted_content ],
            except: [ :password_digest ]
          }.merge(options))
  end

  def formatted_content
    return [] unless content.present?
    content&.scan(/.{1,900}(?:\s|$)/)&.map(&:strip)
  end
end
