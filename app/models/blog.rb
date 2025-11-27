class Blog < ApplicationRecord
  belongs_to :user
  has_one_attached :image, dependent: :destroy
  before_validation :normalize_fields

  validates :title,
            presence: { message: I18n.t("activerecord.errors.models.blog.title.blank") },
            length: { maximum: 50, message: I18n.t("activerecord.errors.models.blog.title.too_long") }

  validates :content,
            presence: { message: I18n.t("activerecord.errors.models.blog.content.blank") },
            length: {
              maximum: 5000,
              message: I18n.t("activerecord.errors.models.blog.content.too_long") }

  validate :acceptable_image

  def image_url
    return unless image.attached?
    Rails.application.routes.url_helpers.url_for(image)
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

  scope :search, ->(search_term) {
    if search_term.present?
      term = "%#{search_term.strip.downcase}%"
      where("LOWER(title) LIKE ? OR LOWER(content) LIKE ?", term, term)
    else
      all
    end
  }

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

  def normalize_fields
    self.title = title&.capitalize&.strip if title.present?
  end
end
