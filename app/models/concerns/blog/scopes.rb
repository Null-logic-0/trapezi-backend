module Blog::Scopes
  extend ActiveSupport::Concern
  included do
    scope :search, ->(search_term) {
      if search_term.present?
        term = "%#{search_term.strip.downcase}%"
        where("LOWER(title) LIKE ? OR LOWER(content) LIKE ?", term, term)
      else
        all
      end
    }
  end
end
