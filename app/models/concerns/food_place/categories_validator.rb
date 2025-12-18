module FoodPlace::CategoriesValidator
  extend ActiveSupport::Concern

  included do
    validate :categories_count_within_limit
    validate :validate_categories_inclusion
  end

  MAX_CATEGORIES = 2
  CATEGORIES = %w[restaurant cafe bar bakery pastry].freeze

  private

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
end
