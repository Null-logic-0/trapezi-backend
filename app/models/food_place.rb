class FoodPlace < ApplicationRecord
  belongs_to :user
  before_validation :normalize_fields
  before_create :set_hidden_for_paid_plan

  # ActiveStorage attachments
  has_many_attached :images
  has_one_attached :menu_pdf

  has_many :favorites, dependent: :destroy
  has_many :favorite_by_users, through: :favorites, source: :user
  has_many :reviews, dependent: :destroy
  has_many :reports, dependent: :destroy

  # Categories
  CATEGORIES = %w[restaurant cafe bar bakery pastry].freeze

  # Helper to display schedule nicely
  MONDAY_FIRST = %w[monday tuesday wednesday thursday friday saturday sunday].freeze

  # Validations
  validates :business_name, :address, :categories, presence: true
  validates :description, presence: true, length: { maximum: 200 }
  validate :free_plan_limit, on: :create

  validate :categories_count_within_limit
  validate :validate_categories_inclusion
  validate :validate_working_schedule_format
  validate :validate_images
  validate :validate_menu_pdf, on: :create

  # --- Phone validation ---
  VALID_PHONE_REGEX = /\A(\+995)?5?\d{9}\z/

  validates :phone, format: {
    with: VALID_PHONE_REGEX,
    message: I18n.t("activerecord.errors.models.food_place.attributes.phone.invalid_format")
  }

  # Geocoding
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  def working_schedule_readable(locale = I18n.locale)
    (working_schedule || {}).slice(*MONDAY_FIRST).map do |day, times|
      from = times["from"]
      to = times["to"]

      # If both from and to are blank,  show "Closed"
      hours = if from.blank? && to.blank?
                I18n.t("activerecord.errors.models.food_place.schedule.closed", locale: locale)
      else
                "#{from}-#{to}"
      end

      day_name = I18n.t("activerecord.errors.models.food_place.days.#{day}", locale: locale)
      "#{day_name}: #{hours}"
    end.join(", ")
  end

  def working_schedule_translated(locale = I18n.locale)
    (working_schedule || {}).slice(*MONDAY_FIRST).transform_keys do |day|
      I18n.t("activerecord.errors.models.food_place.days.#{day}", locale: locale)
    end
  end

  def currently_open(time = Time.current)
    today = time.strftime("%A").downcase
    schedule = working_schedule[today] || {}
    from_time = schedule["from"]
    to_time = schedule["to"]
    return false unless from_time && to_time

    from_hour, from_min = from_time.split(":").map(&:to_i)
    to_hour, to_min = to_time.split(":").map(&:to_i)

    from_datetime = time.change(hour: from_hour, min: from_min)
    to_datetime = time.change(hour: to_hour, min: to_min)

    if from_datetime < to_datetime
      time.between?(from_datetime, to_datetime)
    else
      time >= from_datetime || time <= to_datetime
    end
  end

  def images_url
    return unless images.attached?

    images.map do |img|
      if Rails.env.production?
        bucket = ENV.fetch("AWS_BUCKET_URL")
        "#{bucket}/#{img.key}"
      else
        Rails.application.routes.url_helpers.url_for(img)
      end
    end
  end

  def as_json(options = {})
    super({
            methods: [ :images_url, :menu_url, :working_schedule_readable, :average_rating, :currently_open ],
            except: [ :password_digest, :created_at, :updated_at, :is_open ]
          }.merge(options))
  end

  def menu_url
    return unless menu_pdf.attached?
    Rails.application.routes.url_helpers.url_for(menu_pdf)
  end

  def average_rating
    return 0 if reviews.empty?
    (reviews.sum(:rating).to_f / reviews.size).round(1)
  end

  scope :vip, -> { where(is_vip: true) }
  scope :free, -> { where(is_vip: false) }
  scope :visible, -> { where(hidden: false) }

  scope :search, ->(search_term) {
    if search_term.present?
      term = "%#{search_term.strip.downcase}%"
      where("LOWER(business_name) LIKE ? OR LOWER(description) LIKE ?", term, term)
    else
      all
    end
  }

  private

  def free_plan_limit
    return unless user&.free_plan?
    if user&.plan? && user&.food_places&.exists?
      errors.add(:plan, I18n.t("errors.free_plan"))
    end
  end

  def set_hidden_for_paid_plan
    if user.paid_plan?
      self.hidden = false
    end
  end

  # --- Categories validations ---
  MAX_CATEGORIES = 2

  def categories_count_within_limit
    if categories.size > MAX_CATEGORIES
      errors.add(:categories, I18n.t(
        "activerecord.errors.models.food_place.attributes.categories.too_many",
        count: MAX_CATEGORIES
      ))
    end
  end

  def validate_categories_inclusion
    invalid = categories - CATEGORIES
    return if invalid.empty?
    errors.add(:categories, I18n.t(
      "activerecord.errors.models.food_place.attributes.categories.invalid_entries",
      list: invalid.join(", ")))
  end

  # --- Working schedule validation ---
  def validate_working_schedule_format
    unless working_schedule.is_a?(Hash)
      errors.add(:working_schedule, I18n.t("activerecord.errors.models.food_place.attributes.working_schedule.invalid_format"))
      return
    end

    working_schedule&.each do |day, times|
      unless times.is_a?(Hash) && times.key?("from") && times.key?("to")
        errors.add(:working_schedule, I18n.t("activerecord.errors.models.food_place.attributes.working_schedule.missing_keys", day: day))
        next
      end

      from = times["from"]
      to = times["to"]
      next if from.blank? && to.blank?

      unless from =~ /\A\d{2}:\d{2}\z/ && to =~ /\A\d{2}:\d{2}\z/
        errors.add(:working_schedule,
                   I18n.t("activerecord.errors.models.food_place.attributes.working_schedule.invalid_time_format"))
        next
      end

      if from >= to
        errors.add(:working_schedule,
                   I18n.t("activerecord.errors.models.food_place.attributes.working_schedule.closing_before_opening"))
      end
    end
  end

  # --- Image validations ---
  MAX_IMAGES = 4
  MAX_IMAGE_SIZE_MB = 15
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
  MAX_PDF_SIZE_MB = 15

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

  def normalize_fields
    self.business_name = business_name&.capitalize&.strip if business_name.present?
    self.description = description&.capitalize&.strip if description.present?
  end
end
