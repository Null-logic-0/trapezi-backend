class Api::V1::AdminDashboardStatsController < ApplicationController
  before_action :require_login
  before_action :moderator?

  PERIODS = {
    "1m" => 1.month,
    "3m" => 3.months,
    "6m" => 6.months,
    "1y" => 1.year
  }.freeze
  ALLOWED_DATE_COLUMNS = %i[created_at updated_at].freeze

  def index
    current_from, previous_from, previous_to = time_ranges
    current_to = Time.current

    current = stats_for(current_from, current_to)

    percent =
      if params[:period].present? && previous_from && previous_to
        previous = stats_for(previous_from, previous_to)
        percent_change(current, previous)
      else
        empty_percent
      end

    charts = {
      users: chart_data(User, :created_at, current_from, current_to),
      revenue: chart_data(Payment, :created_at, current_from, current_to, :amount)
    }

    render json: {
      data: current,
      percent: percent,
      charts: charts,
      period: params[:period] || "all"
    }
  end

  private

  # Time ranges
  def time_ranges
    return [ nil, nil, nil ] unless params[:period].present?
    duration = PERIODS[params[:period]]
    return [ nil, nil, nil ] unless duration

    now = Time.current
    current_from = now - duration
    previous_to = current_from
    previous_from = previous_to - duration

    [ current_from, previous_from, previous_to ]
  end

  # Totals stats
  def scoped_count(relation, from_date, to_date)
    relation = relation.where("created_at >= ?", from_date) if from_date
    relation = relation.where("created_at <= ?", to_date) if to_date
    relation
  end

  def stats_for(from_date = nil, to_date = nil)
    {
      users_count: scoped_count(User, from_date, to_date)&.count,
      places_count: scoped_count(FoodPlace, from_date, to_date)&.count,
      paid_account_count: scoped_count(User.where(plan: "pro"), from_date, to_date)&.count,
      vip: scoped_count(FoodPlace.where(is_vip: true), from_date, to_date)&.count,
      total_revenue: scoped_count(Payment, from_date, to_date)&.sum(:amount)
    }
  end

  # Percent calculation
  def percent_change(current, previous)
    current.each_with_object({}) do |(key, value), result|
      prev_value = previous[key] || 0
      result[key] = percentage(value, prev_value)
    end
  end

  def percentage(current, previous)
    return nil if previous.to_f.zero?
    (((current - previous) / previous.to_f) * 100).round(2)
  end

  def empty_percent
    {
      users_count: nil,
      places_count: nil,
      paid_account_count: nil,
      vip: nil,
      total_revenue: nil
    }
  end

  # Chart data (daily counts)
  def chart_data(model, date_column, from_date, to_date, sum_column = nil)
    raise "Invalid column" unless ALLOWED_DATE_COLUMNS.include?(date_column.to_sym)

    records = model.all
    records = records.where(model.arel_table[date_column].gteq(from_date)) if from_date
    records = records.where(model.arel_table[date_column].lteq(to_date)) if to_date

    grouped = if sum_column
                records.group(Arel.sql("DATE(#{date_column})")).sum(sum_column)
    else
                records.group(Arel.sql("DATE(#{date_column})")).count
    end

    grouped.sort.map { |date, value| { date: date.to_s, value: value } }
  end
end
