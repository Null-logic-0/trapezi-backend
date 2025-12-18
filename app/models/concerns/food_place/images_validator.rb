module FoodPlace::ImagesValidator
  extend ActiveSupport::Concern

  MAX_IMAGES = 4
  MAX_IMAGE_SIZE_MB = 15
  VALID_IMAGE_TYPES = %w[image/jpeg image/png image/jpg].freeze

  included do
    validate :validate_images
  end

  private

  def validate_images
    return if Rails.env.test?
    unless images.attached?
      errors.add(:images, I18n.t(
        "activerecord.errors.models.food_place.attributes.images.blank")
      )
      return
    end

    if images.count > MAX_IMAGES
      errors.add(:images, I18n.t(
        "activerecord.errors.models.food_place.attributes.images.too_many",
        count: MAX_IMAGES
      ))
    end

    images.each do |img|
      unless VALID_IMAGE_TYPES.include?(img.content_type)
        errors.add(:images, I18n.t("activerecord.errors.models.food_place.attributes.images.invalid_format"))
      end

      if img.byte_size > MAX_IMAGE_SIZE_MB.megabytes
        errors.add(:images, I18n.t(
          "activerecord.errors.models.food_place.attributes.images.too_large",
          count: MAX_IMAGE_SIZE_MB
        ))
      end
    end
  end
end
