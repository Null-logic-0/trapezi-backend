class Api::V1::FoodPlacesController < ApplicationController
  include Pagination
  before_action :set_food_place, only: %i[ show update destroy toggle_favorite get_reviews create_review delete_review update_review destroy_by_admin ]
  before_action :require_login, except: %i[ index get_vip_places  ]
  before_action :admin?, only: %i[destroy_by_admin get_places_for_admin ]

  def index
    scope = filtered_places(
      FoodPlace
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

  # Favorite Places
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

  def get_places_for_admin
    @food_places = FoodPlace.all.order(created_at: :desc).search(params[:search])
    result = paginate(@food_places)

    render json: {
      data: result[:data].map do |food_place|
        {
          id: food_place.id,
          business_name: food_place.business_name,
          images: food_place.images_url,
          categories: food_place.categories,
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

  def filtered_places(scope)
    if params[:categories].present?
      categories = params[:categories].split(",").map(&:strip).map(&:downcase)
      scope = scope.where("categories && ARRAY[?]::varchar[]", categories)
    end

    scope
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
