module Report::ReportHelpers
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_fields

    before_create :generate_report_code
  end

  private

  def generate_report_code
    last_number = Report.maximum(:id).to_i + 1
    self.report_code = "REP#{format('%03d', last_number)}"
  end

  def normalize_fields
    self.title = title&.capitalize&.strip if title.present?
  end
end
