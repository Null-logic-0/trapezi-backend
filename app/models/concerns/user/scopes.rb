module User::Scopes
  extend ActiveSupport::Concern

  included do
    scope :admin, -> { where(is_admin: true) }
    scope :moderator, -> { where(moderator: true) }
    scope :owner, -> { where(business_owner: true) }
    scope :user, -> { where(is_admin: false, moderator: false, business_owner: false) }
    scope :blocked, -> { where(is_blocked: true) }
    scope :active, -> { where(is_blocked: false) }

    scope :search, ->(search_term) {
      if search_term.present?
        term = "%#{search_term.strip.downcase}%"
        where("LOWER(name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(email) LIKE ?", term, term, term)
      else
        all
      end
    }
  end
end
