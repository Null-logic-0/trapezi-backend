class Report < ApplicationRecord
  belongs_to :user
  belongs_to :food_place
  before_validation :normalize_fields

  before_create :generate_report_code

  enum :status, {
    pending: 0,
    dismissed: 1,
    resolved: 2
  }

  validates :title, presence: { message: I18n.t("activerecord.errors.models.report.title.blank") }
  validates :description, presence: { message: I18n.t("activerecord.errors.models.report.description.blank") }

  scope :pending, -> { where(status: "pending") }
  scope :dismissed, -> { where(status: "dismissed") }
  scope :resolved, -> { where(status: "resolved") }

  scope :search, ->(search_term) {
    if search_term.present?
      term = "%#{search_term.strip.downcase}%"
      where("LOWER(title) LIKE ? OR LOWER(report_code) LIKE ?", term, term)
    else
      all
    end
  }

  private

  def generate_report_code
    last_number = Report.maximum(:id).to_i + 1
    self.report_code = "REP#{format('%03d', last_number)}"
  end

  def normalize_fields
    self.title = title&.upcase&.strip if title.present?
  end
end
