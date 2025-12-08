class Api::V1::ReviewsController < ApplicationController
  before_action :require_login
  before_action :set_food_place
  before_action :check_review_content, only: [ :create_review, :update_review ]

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

  def check_review_content
    comment = review_params[:comment]
    return unless comment.present?

    if ::Moderations::TextModeration.check?(comment)
      current_user&.add_strike!

      if action_name == "update_review"
        review = current_user&.reviews&.find_by(id: params[:review_id], food_place_id: @food_place.id)
        review&.destroy
      end

      render json: {
        error: I18n.t("errors.disallowed_content"),
        user_blocked: current_user&.is_blocked
      }, status: :forbidden
    end
  end

  def review_params
    params.permit(:rating, :comment)
  end

  def set_food_place
    id_param = params[:id] || params[:place_id]
    @food_place = FoodPlace.find(id_param)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Food place not found" }, status: :not_found
  end
end
