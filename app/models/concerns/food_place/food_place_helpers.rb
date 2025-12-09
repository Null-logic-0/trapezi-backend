module FoodPlace::FoodPlaceHelpers
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_fields
    before_create :set_hidden_for_paid_plan

    validate :free_plan_limit, on: :create
  end

  private

  def free_plan_limit
    return unless user&.free_plan?
    if user&.plan? && user&.food_places&.exists?
      errors.add(:plan, I18n.t("errors.free_plan"))
    end
  end

  def set_hidden_for_paid_plan
    if user.paid_plan?
      self.hidden = false
    end
  end

  def normalize_fields
    self.business_name = business_name&.capitalize&.strip if business_name.present?
    self.description = description&.capitalize&.strip if description.present?
  end
end
