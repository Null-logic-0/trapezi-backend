class FoodPlace < ApplicationRecord
  belongs_to :user

  # ActiveStorage attachments
  has_many_attached :images
  has_one_attached :menu_pdf
  has_one_attached :document_pdf

  has_many :favorites, dependent: :destroy
  has_many :favorite_by_users, through: :favorites, source: :user
  has_many :reviews, dependent: :destroy
  has_many :reports, dependent: :destroy

  include FoodPlace::PdfValidator
  include FoodPlace::ImagesValidator
  include FoodPlace::WorkingScheduleValidator
  include FoodPlace::CategoriesValidator
  include FoodPlace::WorkingScheduleMethods
  include FoodPlace::FoodPlaceHelpers
  include AttachmentUrl

  # Validations
  validates :business_name, :address, :categories, presence: true
  validates :description, presence: true, length: { maximum: 200 }
  validates :identification_code, presence: true, on: :create

  # --- Phone validation ---
  VALID_PHONE_REGEX = /\A(\+995)?5?\d{9}\z/

  validates :phone, format: {
    with: VALID_PHONE_REGEX,
    message: I18n.t("activerecord.errors.models.food_place.attributes.phone.invalid_format")
  }

  # Geocoding
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  def images_url
    files_url(images)
  end

  def menu_url
    file_url(menu_pdf)
  end

  def document_url
    file_url(document_pdf)
  end

  def as_json(options = {})
    super({
            methods: [ :images_url, :menu_url, :document_url, :working_schedule_readable, :average_rating, :currently_open ],
            except: [ :password_digest, :created_at, :updated_at, :is_open ]
          }.merge(options))
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
end
