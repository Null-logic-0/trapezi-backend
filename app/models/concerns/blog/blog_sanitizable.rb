module Blog::BlogSanitizable
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_fields
  end

  private

  def normalize_fields
    self.title = title&.capitalize&.strip if title.present?
  end
end
