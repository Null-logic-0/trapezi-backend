module VideoTutorial::VideoValidator
  extend ActiveSupport::Concern

  included do
    validate :acceptable_video
  end

  private

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

    acceptable_types = %w[video/mp4 video/quicktime]

    unless acceptable_types.include?(video.content_type)
      errors.add(:video, I18n.t("activerecord.errors.models.video.video.invalid_format"))
    end
  end
end
