class Api::V1::FoodPlacesController < ApplicationController
  before_action :set_food_place, only: %i[ show update destroy ]
  before_action :require_login, except: %i[ index  ]

  def index
    @food_places = FoodPlace.all
    render json: @food_places.as_json, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def my_businesses
    @food_places = current_user&.food_places&.order(created_at: :desc)
    render json: @food_places.as_json, status: :ok
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
      render json: { success: false, errors: @food_place.errors.full_messages }, status: :unprocessable_entity
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

  private

  def set_food_place
    @food_place = FoodPlace.find(params[:id])
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
      :working_schedule,
      images: [],

    )

    if permitted[:working_schedule].is_a?(String)
      permitted[:working_schedule] = JSON.parse(permitted[:working_schedule]) rescue {}
    end

    permitted
  end
end
