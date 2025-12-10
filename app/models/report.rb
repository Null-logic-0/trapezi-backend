class Report < ApplicationRecord
  belongs_to :user
  belongs_to :food_place

  include Report::ReportHelpers
  include Report::Scopes

  enum :status, {
    pending: 0,
    dismissed: 1,
    resolved: 2
  }

  validates :title, presence: { message: I18n.t("activerecord.errors.models.report.title.blank") }
  validates :description, presence: { message: I18n.t("activerecord.errors.models.report.description.blank") }
end
