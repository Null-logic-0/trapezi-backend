module FoodPlaces
  class FilterService
    def initialize(scope: FoodPlace.all, params:)
      @scope = scope
      @params = params
    end

    def call
      scoped = @scope
      scoped = scoped.visible if @params[:visible_only]

      if @params[:categories].present?
        categories = Array(@params[:categories]).map(&:downcase)
        scoped = scoped.where("categories && ARRAY[?]::varchar[]", categories)
      end

      scoped = scoped.left_joins(:reviews)
                     .select("food_places.*, COALESCE(AVG(reviews.rating), 0) AS average_rating")
                     .group("food_places.id")

      scoped = scoped.search(@params[:search]) if @params[:search].present?

      scoped = scoped.order(ordering)
      scoped
    end

    private

    def ordering
      @params[:vip_first] ? "is_vip DESC, average_rating DESC" : "average_rating DESC"
    end
  end
end
