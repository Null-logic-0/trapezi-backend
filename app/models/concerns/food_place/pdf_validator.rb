module FoodPlace::PdfValidator
  extend ActiveSupport::Concern

  class_methods do
    def max_pdf_size_mb
      const_defined?(:MAX_PDF_SIZE_MB) ? const_get(:MAX_PDF_SIZE_MB) : 10
    end
  end

  included do
    def validate_pdf(attachment, attribute)
      unless attachment&.attached?
        errors.add(
          attribute,
          I18n.t("activerecord.errors.models.food_place.attributes.pdf.blank")
        )
        return
      end

      unless attachment.content_type == "application/pdf"
        errors.add(
          attribute,
          I18n.t("activerecord.errors.models.food_place.attributes.pdf.invalid_format")
        )
      end

      if attachment.byte_size > self.class.max_pdf_size_mb.megabytes
        errors.add(
          attribute,
          I18n.t("activerecord.errors.models.food_place.attributes.pdf.too_large", count: self.class.max_pdf_size_mb)
        )
      end
    end
  end
end
