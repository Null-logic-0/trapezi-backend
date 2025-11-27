class Api::V1::VideoTutorialsController < ApplicationController
  include Pagination
  before_action :require_login, except: [ :index, :show ]
  before_action :moderator?, except: [ :index, :show ]
  before_action :set_video_tutorial, except: [ :index, :create ]

  def index
    @video_tutorials = VideoTutorial.all.order(created_at: :desc)
    result = paginate(@video_tutorials)

    render json: {
      data: result[:data].as_json,
      pagination: result[:meta]
    }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    render json: @video_tutorial, status: :ok
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def create
    uploaded_video = params[:video]
    unless uploaded_video
      render json: { success: false, errors: I18n.t(
        "activerecord.errors.models.video.video.blank")
      }, status: :bad_request
      return
    end
    duration = Videotime.get_video_time(uploaded_video.path)
    @video_tutorial = current_user&.video_tutorials&.build(video_tutorials_params)
    @video_tutorial.duration = duration

    if @video_tutorial.save
      render json: @video_tutorial, success: true, status: :created
    else
      render json: {
        success: false,
        errors: formatted_errors(@video_tutorial)
      }, status: :unprocessable_entity
    end
  end

  def update
    @video_tutorial = current_user&.video_tutorials&.find_by(id: params[:id])

    unless @video_tutorial
      render json: { error: "Not authorized or not found" }, status: :forbidden
      return
    end

    if @video_tutorial.update(video_tutorials_params)
      render json: @video_tutorial.as_json, status: :ok
    else
      render json: { success: false, errors: formatted_errors(@video_tutorial) }, status: :unprocessable_entity
    end
  end

  def destroy
    if @video_tutorial.user == current_user
      @video_tutorial.destroy!
      render json: { message: "Deleted successfully!" }
    else
      render json: { error: "Not authorized" }, status: :forbidden
    end

  rescue ActiveRecord::RecordNotFound
    render json: { error: "video tutorial not found" }, status: :not_found
  end

  private

  def format_duration(seconds)
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end

  def set_video_tutorial
    @video_tutorial = VideoTutorial.find(params[:id])
  end

  def video_tutorials_params
    params.permit(:title, :description, :thumbnail, :video)
  end
end
