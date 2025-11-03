class FoodPlace < ApplicationRecord
  belongs_to :user

  # ActiveStorage attachments
  has_many_attached :images
  has_one_attached :menu_pdf

  # Categories
  CATEGORIES = %w[restaurant cafe bar bakery pastry].freeze

  # Validations
  validates :business_name, :address, :categories, presence: true
  validates :description, presence: true, length: { maximum: 200 }

  validate :categories_count_within_limit
  validate :validate_categories_inclusion
  validate :validate_working_schedule_format
  validate :validate_images
  validate :validate_menu_pdf

  # Geocoding
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  # Helper to display schedule nicely
  def working_schedule_readable
    (working_schedule || {}).map do |day, times|
      from = times["from"] || "Closed"
      to = times["to"] || "Closed"
      "#{day.to_s.humanize}: #{from}-#{to}"
    end.join(", ")
  end

  private

  # --- Categories validations ---
  MAX_CATEGORIES = 3

  def categories_count_within_limit
    if categories.size > MAX_CATEGORIES
      errors.add(:categories, "maximum #{MAX_CATEGORIES} categories allowed")
    end
  end

  def validate_categories_inclusion
    invalid = categories - CATEGORIES
    return if invalid.empty?
    errors.add(:categories, "include invalid entries: #{invalid.join(', ')}")
  end

  # --- Working schedule validation ---
  def validate_working_schedule_format
    unless working_schedule.is_a?(Hash)
      errors.add(:working_schedule, "must be a hash with per-day schedule")
      return
    end

    working_schedule&.each do |day, times|
      unless times.is_a?(Hash) && times.key?("from") && times.key?("to")
        errors.add(:working_schedule, "#{day} must have 'from' and 'to' keys")
        next
      end

      from = times["from"]
      to = times["to"]
      next if from.blank? && to.blank?

      unless from =~ /\A\d{2}:\d{2}\z/ && to =~ /\A\d{2}:\d{2}\z/
        errors.add(:working_schedule, "#{day}: times must be in HH:MM format")
        next
      end

      if from >= to
        errors.add(:working_schedule, "#{day}: closing time must be after opening time")
      end
    end
  end

  # --- Image validations ---
  MAX_IMAGES = 5
  MAX_IMAGE_SIZE_MB = 5
  VALID_IMAGE_TYPES = %w[image/jpeg image/png image/jpg].freeze

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

  # --- Menu PDF validations ---
  MAX_PDF_SIZE_MB = 10

  def validate_menu_pdf
    unless menu_pdf.attached?
      errors.add(:menu_pdf, I18n.t("activerecord.errors.models.food_place.attributes.menu_pdf.blank"))
      return
    end

    unless menu_pdf.content_type == "application/pdf"
      errors.add(:menu_pdf, I18n.t("activerecord.errors.models.food_place.attributes.menu_pdf.invalid_format"))
    end

    if menu_pdf.byte_size > MAX_PDF_SIZE_MB.megabytes
      errors.add(:menu_pdf, I18n.t(
        "activerecord.errors.models.food_place.attributes.menu_pdf.too_large",
        count: MAX_PDF_SIZE_MB
      ))
    end
  end
end
