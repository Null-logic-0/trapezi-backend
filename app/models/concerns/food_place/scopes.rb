module FoodPlace::Scopes
  extend ActiveSupport::Concern
  included do
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
end
