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
      schedule = working_schedule[today] || {}
      from_time = schedule["from"]
      to_time = schedule["to"]
      return false unless from_time && to_time

      from_hour, from_min = from_time.split(":").map(&:to_i)
      to_hour, to_min = to_time.split(":").map(&:to_i)

      from_datetime = time.change(hour: from_hour, min: from_min)
      to_datetime = time.change(hour: to_hour, min: to_min)

      if from_datetime < to_datetime
        time.between?(from_datetime, to_datetime)
      else
        time >= from_datetime || time <= to_datetime
      end
    end
  end
end
