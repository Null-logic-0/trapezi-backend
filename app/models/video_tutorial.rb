class VideoTutorial < ApplicationRecord
  belongs_to :user

  before_validation :normalize_fields

  has_one_attached :thumbnail, dependent: :destroy
  has_one_attached :video, dependent: :destroy

  validates :title,
            presence: { message: I18n.t("activerecord.errors.models.video.title.blank") },
            length: { maximum: 50, message: I18n.t("activerecord.errors.models.video.title.too_long") }

  validates :description,
            presence: { message: I18n.t("activerecord.errors.models.video.description.blank") },
            length: { maximum: 150, message: I18n.t("activerecord.errors.models.video.title.too_long") }

  validate :acceptable_thumbnail
  validate :acceptable_video

  def thumbnail_url
    return unless thumbnail.attached?
    Rails.application.routes.url_helpers.url_for(thumbnail)
  end

  def video_url
    return unless video.attached?
    Rails.application.routes.url_helpers.url_for(video)
  end

  def formatted_duration
    return nil unless duration.present?
    total_seconds = duration.to_i
    minutes = total_seconds / 60
    seconds = total_seconds % 60
    format("%d:%02d", minutes, seconds)
  end

  def as_json(options = {})
    super({
            methods: [ :thumbnail_url, :video_url, :formatted_duration ],
            except: [ :password_digest, :duration ]
          }.merge(options))
  end

  private

  def acceptable_thumbnail
    return if Rails.env.test?
    unless thumbnail.attached?
      errors.add(:thumbnail, I18n.t(
        "activerecord.errors.models.video.thumbnail.blank")
      )
      return
    end

    unless thumbnail.byte_size <= 8.megabyte
      errors.add(:thumbnail, I18n.t("activerecord.errors.models.video.thumbnail.too_large"))
    end

    acceptable_types = %w[image/png image/jpg image/jpeg]
    unless acceptable_types.include? thumbnail.content_type
      errors.add(:thumbnail, I18n.t("activerecord.errors.models.video.thumbnail.invalid_format"))
    end
  end

  def acceptable_video
    return if Rails.env.test?
    unless video.attached?
      errors.add(:video, I18n.t(
        "activerecord.errors.models.video.video.blank")
      )
      return
    end

    unless video.byte_size <= 800.megabytes
      errors.add(:video, I18n.t("activerecord.errors.models.video.video.too_large"))
    end

    acceptable_types = %w[video/mov video/mp4]
    unless acceptable_types.include?(video.content_type)
      errors.add(:video, I18n.t("activerecord.errors.models.video.video.invalid_format"))
    end
  end

  def normalize_fields
    self.title = title&.capitalize&.strip if title.present?
    self.description = description&.capitalize&.strip if description.present?
  end
end
