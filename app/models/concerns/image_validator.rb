module ImageValidator
  extend ActiveSupport::Concern

  class_methods do
    # Override in model if needed
    def image_max_size_mb
      12
    end

    def image_content_types
      %w[image/png image/jpg image/jpeg]
    end
  end

  included do
    def validate_image(attachment)
      return if Rails.env.test?

      unless attachment.attached?
        errors.add(attachment.name, I18n.t(
          "errors.image.blank")
        )

        return
      end

      validate_attachment_size(attachment)
      validate_attachment_format(attachment)
    end

    private

    def validate_attachment_size(attachment)
      max_size = self.class.image_max_size_mb.megabytes

      if attachment.byte_size > max_size
        errors.add(
          attachment.name,
          I18n.t("errors.image.too_large", count: self.class.image_max_size_mb)
        )
      end
    end

    def validate_attachment_format(attachment)
      unless self.class.image_content_types.include?(attachment.content_type)
        errors.add(
          attachment.name,
          I18n.t("errors.image.invalid_format")
        )
      end
    end
  end
end
