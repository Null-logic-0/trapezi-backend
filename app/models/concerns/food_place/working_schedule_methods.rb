module FoodPlace::WorkingScheduleMethods
  extend ActiveSupport::Concern
  MONDAY_FIRST = %w[monday tuesday wednesday thursday friday saturday sunday].freeze

  included do
    def working_schedule_readable(locale = I18n.locale)
      (working_schedule || {}).slice(*MONDAY_FIRST).map do |day, times|
        from = times["from"]
        to = times["to"]

        hours = if from.blank? && to.blank?
                  I18n.t("activerecord.errors.models.food_place.schedule.closed", locale: locale)
        else
                  "#{from}-#{to}"
        end

        day_name = I18n.t("activerecord.errors.models.food_place.days.#{day}", locale: locale)
        "#{day_name}: #{hours}"
      end.join(", ")
    end

    def working_schedule_translated(locale = I18n.locale)
      (working_schedule || {}).slice(*MONDAY_FIRST).transform_keys do |day|
        I18n.t("activerecord.errors.models.food_place.days.#{day}", locale: locale)
      end
    end

    def currently_open(time = Time.current)
      today = time.strftime("%A").downcase
      schedule = working_schedule[today]
      return false unless schedule&.dig("from") && schedule&.dig("to")

      now_minutes = time.hour * 60 + time.min
      from_minutes = to_minutes(schedule["from"])
      to_minutes = to_minutes(schedule["to"])

      if from_minutes < to_minutes
        now_minutes >= from_minutes && now_minutes < to_minutes
      else
        now_minutes >= from_minutes || now_minutes < to_minutes
      end
    end
  end

  private

  def to_minutes(time_str)
    h, m = time_str.split(":").map(&:to_i)
    h * 60 + m
  end
end
