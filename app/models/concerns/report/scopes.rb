module Report::Scopes
  extend ActiveSupport::Concern

  included do
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
  end
end
