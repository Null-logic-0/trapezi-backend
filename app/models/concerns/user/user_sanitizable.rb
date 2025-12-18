module User::UserSanitizable
  extend ActiveSupport::Concern

  class_methods do
    def image_max_size_mb
      8
    end

    def image_content_types
      %w[image/png image/jpg image/jpeg]
    end
  end

  included do
    before_validation :normalize_fields
    validate :acceptable_image
  end

  def password_required?
    new_record? || password.present?
  end

  def normalize_fields
    self.email = email&.downcase&.strip if email.present?
    self.name = name&.strip&.capitalize if name.present?
    self.last_name = last_name&.strip&.capitalize if last_name.present?
  end

  private

  def acceptable_image
    return if Rails.env.test?
    validate_attachment_size(avatar)
    validate_attachment_format(avatar)
  end

  def validate_attachment_size(attachment)
    return unless attachment&.byte_size
    max_size = self.class.image_max_size_mb.megabytes

    if attachment.byte_size > max_size
      errors.add(
        attachment.name,
        I18n.t("errors.image.too_large", count: self.class.image_max_size_mb)
      )
    end
  end

  def validate_attachment_format(attachment)
    return unless attachment&.content_type
    unless self.class.image_content_types.include?(attachment.content_type)
      errors.add(
        attachment.name,
        I18n.t("errors.image.invalid_format")
      )
    end
  end
end
