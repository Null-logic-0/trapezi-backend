class Api::V1::ReportsController < ApplicationController
  include Pagination
  before_action :require_login
  before_action :admin?, except: :create
  before_action :set_food_place, except: [ :index, :show ]
  before_action :set_report, except: [ :index, :create ]

  def index
    @reports = Report.all.order(created_at: :desc).search(params[:search])
    result = paginate(@reports)

    render json: {
      data: result[:data].as_json(include: report_includes),
      pagination: result[:meta]
    }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    render json: @report.as_json(include: report_includes), status: :ok
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def create
    report = current_user&.reports&.build(report_params.merge(food_place_id: @food_place.id))
    if report&.save

      render json: report.as_json, status: :created
    else
      render json: { success: false, errors: formatted_errors(report) }, status: :unprocessable_entity
    end
  end

  def update
    if @report.update(update_report_params)
      handle_offending_content(@report) if @report.resolved?

      render json: @report.as_json(include: {
        food_place: { only: %i[hidden] }
      }), status: :ok
    else
      render json: { success: false, errors: formatted_errors(@report) }, status: :unprocessable_entity
    end
  end

  def destroy
    if @report.destroy
      render json: { success: true, message: "Deleted successfully!" }, status: :ok
    else
      render json: { success: false, errors: formatted_errors(@report) }, status: :unprocessable_entity
    end
  end

  private

  def set_report
    @report = Report.find_by!(id: params[:report_id] || params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Report not found" }, status: :not_found
  end

  def set_food_place
    id_param = params[:id] || params[:place_id]
    @food_place = FoodPlace.find(id_param)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Food place not found" }, status: :not_found
  end

  def report_params
    params.permit(:title, :description)
  end

  def update_report_params
    params.permit(:status)
  end

  def self.search
    if params[:search].present?
      search_term = "%#{params[:search].strip.downcase}%"
      scope = scope.where("LOWER(title) LIKE ? OR LOWER(report_code) LIKE ?", "%#{search_term}%")
    end
    scope
  end

  def report_includes
    {
      user: { only: %i[id name last_name email] },
      food_place: { only: %i[id place_code business_name categories address phone] }
    }
  end

  def handle_offending_content(report)
    if report.user.reports.where(status: 2)
      report.food_place.update(hidden: true)
      report.user.update(is_blocked: true)
      DeleteFoodPlaceJob.set(wait: 30.days).perform_later(report.food_place.id)

    end
  end
end
