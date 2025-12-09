module FoodPlace::WorkingScheduleValidator
  extend ActiveSupport::Concern

  included do
    validate :validate_working_schedule_format
  end

  def validate_working_schedule_format
    return unless Rails.env.development? || Rails.env.production?

    if working_schedule.blank?
      errors.add(
        :working_schedule,
        I18n.t("activerecord.errors.models.food_place.attributes.working_schedule.blank")
      )
      return
    end
    unless working_schedule.is_a?(Hash)
      errors.add(:working_schedule, I18n.t("activerecord.errors.models.food_place.attributes.working_schedule.invalid_format"))
      return
    end

    working_schedule&.each do |day, times|
      unless times.is_a?(Hash) && times.key?("from") && times.key?("to")
        errors.add(:working_schedule, I18n.t("activerecord.errors.models.food_place.attributes.working_schedule.missing_keys", day: day))
        next
      end

      from = times["from"]
      to = times["to"]
      next if from.blank? && to.blank?

      unless from =~ /\A\d{2}:\d{2}\z/ && to =~ /\A\d{2}:\d{2}\z/
        errors.add(:working_schedule,
                   I18n.t("activerecord.errors.models.food_place.attributes.working_schedule.invalid_time_format"))
        next
      end

      if from >= to
        errors.add(:working_schedule,
                   I18n.t("activerecord.errors.models.food_place.attributes.working_schedule.closing_before_opening"))
      end
    end
  end
end
