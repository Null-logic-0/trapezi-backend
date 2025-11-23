class Api::V1::FavoritesController < ApplicationController
  include Pagination
  before_action :require_login
  before_action :set_food_place, only: [ :toggle_favorite ]

  def favorites
    scope = filtered_places(
      current_user&.favorite_food_places&.order(created_at: :desc)&.search(params[:search])
    )
    result = paginate(scope)
    render json: {
      data: result[:data].as_json,
      pagination: result[:meta]
    }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def toggle_favorite
    favorite = current_user&.favorites&.find_by(food_place: @food_place)

    if favorite
      favorite.destroy
      render json: { success: true, favorite: false, message: "Removed from favorites" }, status: :ok
    else
      current_user&.favorites&.create(food_place: @food_place)
      render json: { success: true, favorite: true, message: "Added to favorites" }, status: :ok
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Food place not found" }, status: :not_found
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def set_food_place
    id_param = params[:id] || params[:place_id]
    @food_place = FoodPlace.find(id_param)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Food place not found" }, status: :not_found
  end
end
