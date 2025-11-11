module Pagination
  extend ActiveSupport::Concern

  included do
    def paginate(scope)
      per_page = (params[:per_page].presence || 10).to_i
      page = (params[:page].presence || 1).to_i

      paginated_scope = scope.page(page).per(per_page)

      {
        data: paginated_scope,
        meta: {
          current_page: paginated_scope.current_page,
          per_page: per_page,
          total_pages: paginated_scope.total_pages,
          total_count: paginated_scope.total_count
        }
      }
    end
  end
end
