class Api::V1::FoodPlacesController < ApplicationController
  before_action :set_food_place, only: %i[ show update destroy toggle_favorite get_reviews create_review delete_review update_review ]
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

  # Favorite Places
  def favorites
    @favorite_places = current_user&.favorite_food_places&.order(created_at: :desc)
    render json: @favorite_places.as_json, status: :ok
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

  # Reviews

  def get_reviews
    @reviews = @food_place.reviews.includes(:user).order(created_at: :desc)
    render json: @reviews.as_json(
      include: { user: { only: %i[id name last_name] } },
      except: %i[updated_at]
    ), status: :ok
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def create_review
    review = current_user&.reviews&.build(review_params.merge(food_place_id: @food_place.id))

    if review
      review.save
      render json: review.as_json(include: { user: { only: %i[id name last_name] } }), status: :created
    else
      render json: { success: false, errors: formatted_errors(review) }, status: :unprocessable_entity
    end
  end

  def update_review
    review = current_user&.reviews&.find_by(id: params[:review_id], food_place_id: @food_place.id)

    unless review
      render json: { error: "Review not found or not authorized" }, status: :forbidden
      return
    end

    if review.update(review_params)
      render json: review.as_json, status: :ok
    else
      render json: { success: false, errors: formatted_errors(review) }, status: :unprocessable_entity
    end
  end

  def delete_review
    review = current_user&.reviews&.find_by(id: params[:review_id], food_place_id: @food_place.id)

    unless review
      render json: { error: "Review not found or not authorized" }, status: :forbidden
      return
    end

    review.destroy!
    render json: { success: true, message: "Review deleted successfully" }, status: :ok
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

  def review_params
    params.permit(:rating, :comment)
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
