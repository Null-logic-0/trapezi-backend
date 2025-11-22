class Api::V1::BlogsController < ApplicationController
  include Pagination
  before_action :require_login, except: %i[ index show  ]
  before_action :moderator?, except: %i[ index show ]
  before_action :set_blog, only: %i[ show update destroy  ]

  def index
    @blogs = Blog.all.order(created_at: :desc).search(params[:search])
    result = paginate(@blogs)

    render json: {
      data: result[:data].as_json,
      pagination: result[:meta]
    }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    render json: @blog.as_json, status: :ok
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def create
    @blog = current_user&.blogs&.build(blog_params)

    if @blog.save
      render json: @blog, success: true, status: :created
    else
      render json: {
        success: false,
        errors: formatted_errors(@blog)
      }, status: :unprocessable_entity
    end
  end

  def update
    @blog = current_user&.blogs&.find_by(id: params[:id])

    unless @blog
      render json: { error: "Not authorized or not found" }, status: :forbidden
      return
    end

    if @blog.update(blog_params)
      render json: @blog.as_json, status: :ok
    else
      render json: { success: false, errors: formatted_errors(@blog) }, status: :unprocessable_entity
    end
  end

  def destroy
    if @blog.user == current_user
      @blog.destroy!
      render json: { message: "Deleted successfully!" }
    else
      render json: { error: "Not authorized" }, status: :forbidden
    end

  rescue ActiveRecord::RecordNotFound
    render json: { error: "Blog not found" }, status: :not_found
  end

  private

  def blog_params
    params.permit(:title, :content, :image)
  end

  def set_blog
    @blog = Blog.find(params[:id])
  end
end
