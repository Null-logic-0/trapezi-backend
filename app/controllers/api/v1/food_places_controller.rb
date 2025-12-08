class Api::V1::FoodPlacesController < ApplicationController
  include Pagination
  before_action :set_food_place, only: %i[ show update destroy destroy_by_admin update_by_admin ]
  before_action :require_login, except: %i[ index get_vip_places  ]
  before_action :admin?, only: %i[destroy_by_admin get_places_for_admin update_by_admin ]
  before_action :validate_nsfw_images, only: %i[create update]

  def index
    scope = filtered_places(
      FoodPlace
        .visible
        .left_joins(:reviews)
        .select("food_places.*, COALESCE(AVG(reviews.rating), 0) AS average_rating")
        .group("food_places.id")
        .order("is_vip DESC, average_rating DESC")
        .search(params[:search])
    )

    result = paginate(scope)

    render json: {
      data: result[:data].as_json,
      pagination: result[:meta]
    }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def get_vip_places
    scope = filtered_places(
      FoodPlace.where(is_vip: true)
               .left_joins(:reviews)
               .select("food_places.*, COALESCE(AVG(reviews.rating), 0) AS average_rating")
               .group("food_places.id")
               .order("average_rating DESC").search(params[:search])
    )

    result = paginate(scope)
    render json: {
      data: result[:data].as_json,
      pagination: result[:meta]
    }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def my_businesses
    scope = filtered_places(
      current_user&.food_places&.order(created_at: :desc)&.search(params[:search])
    )

    result = paginate(scope)
    render json: {
      data: result[:data].as_json,
      pagination: result[:meta]
    }, status: :ok

  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def show
    render json: @food_place.as_json, status: :ok
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def create
    @food_place = current_user&.food_places&.build(food_place_params)

    if @food_place.save
      render json: @food_place, success: true, status: :created

    else
      render json: {
        success: false,
        errors: formatted_errors(@food_place)
      }, status: :unprocessable_entity
    end
  end

  def update
    @food_place = current_user&.food_places&.find_by(id: params[:id])

    unless @food_place
      render json: { error: "Not authorized or not found" }, status: :forbidden
      return
    end

    if @food_place.update(food_place_params)
      render json: @food_place.as_json, status: :ok
    else
      render json: { success: false, errors: formatted_errors(@food_place) }, status: :unprocessable_entity
    end
  end

  def destroy
    if @food_place.user == current_user
      @food_place.destroy!
      render json: { message: "Deleted successfully!" }
    else
      render json: { error: "Not authorized" }, status: :forbidden
    end

  rescue ActiveRecord::RecordNotFound
    render json: { error: "Food place not found" }, status: :not_found
  end

  # Admin

  def destroy_by_admin
    unless current_user
      render json: { success: false, error: "Not authorized" }, status: :forbidden
      return
    end

    if @food_place
      @food_place.destroy
      render json: { success: true, message: "Deleted successfully" }, status: :ok
    else
      render json: { success: false, error: "Food place not found" }, status: :not_found
    end
  end

  def update_by_admin
    unless current_user
      render json: { success: false, error: "Not authorized" }, status: :forbidden
      return
    end

    if @food_place&.update(admin_params)
      render json: @food_place.as_json, status: :ok
    else
      render json: { success: false, errors: @food_place&.errors }, status: :unprocessable_entity
    end
  end

  def get_places_for_admin
    scope = filtered_places(FoodPlace.all.order(created_at: :desc).search(params[:search]))
    result = paginate(scope)

    render json: {
      data: result[:data].map do |food_place|
        {
          id: food_place.id,
          business_name: food_place.business_name,
          images: food_place.images_url,
          categories: food_place.categories,
          is_vip: food_place.is_vip,
          created_at: food_place.created_at,
          user: {
            name: food_place.user&.name,
            last_name: food_place.user&.last_name,
            avatar_url: food_place.user&.avatar_url
          }
        }
      end,
      pagination: result[:meta]
    }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def validate_nsfw_images
    raw_images = params[:images] || params.dig(:images)
    return unless raw_images.present?

    images_to_check = Array(raw_images).select do |image|
      image.is_a?(ActionDispatch::Http::UploadedFile)
    end

    return if images_to_check.empty?

    if Moderations::ImageModeration.any_nsfw?(images_to_check)
      render json: {
        success: false,
        errors: { nsfw: I18n.t("errors.disallowed_images") }
      }, status: :forbidden
      false
    end
  end

  def self.search
    if params[:search].present?
      search_term = "%#{params[:search].strip.downcase}%"
      scope = scope.where("LOWER(business_name) LIKE ?", "%#{search_term}%")
    end
    scope
  end

  def set_food_place
    id_param = params[:id] || params[:place_id]
    @food_place = FoodPlace.find(id_param)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Food place not found" }, status: :not_found
  end

  def admin_params
    params.permit(:is_vip)
  end

  def food_place_params
    permitted = params.permit(
      :business_name,
      :description,
      :menu_pdf,
      :address,
      { categories: [] },
      :website,
      :facebook,
      :instagram,
      :tiktok,
      :phone,
      :working_schedule,
      images: [],

    )

    if permitted[:working_schedule].is_a?(String)
      permitted[:working_schedule] = JSON.parse(permitted[:working_schedule]) rescue {}
    end

    permitted
  end
end
