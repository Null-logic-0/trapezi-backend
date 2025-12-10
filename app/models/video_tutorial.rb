class VideoTutorial < ApplicationRecord
  belongs_to :user

  has_one_attached :thumbnail, dependent: :destroy
  has_one_attached :video, dependent: :destroy

  include ImageValidator
  include AttachmentUrl
  include VideoTutorial::VideoValidator
  include VideoTutorial::VideoSanitizable

  validates :title,
            presence: { message: I18n.t("activerecord.errors.models.video.title.blank") },
            length: { maximum: 50, message: I18n.t("activerecord.errors.models.video.title.too_long") }

  validates :description,
            presence: { message: I18n.t("activerecord.errors.models.video.description.blank") },
            length: { maximum: 150, message: I18n.t("activerecord.errors.models.video.description.too_long") }

  validate -> { validate_image(thumbnail) }

  def thumbnail_url
    file_url(thumbnail)
  end

  def video_url
    file_url(video)
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
end
