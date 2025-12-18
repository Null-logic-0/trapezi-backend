module FoodPlaces
  class FoodPlaceAdminSerializer
    def initialize(food_place)
      @food_place = food_place
    end

    def as_json
      { id: @food_place.id,
        business_name: @food_place.business_name,
        images: @food_place.images_url,
        categories: @food_place.categories,
        is_vip: @food_place.is_vip,
        identification_code: @food_place.identification_code,
        document_url: @food_place.document_url,
        created_at: @food_place.created_at,
        user: {
          name: @food_place.user&.name,
          last_name: @food_place.user&.last_name,
          avatar_url: @food_place.user&.avatar_url
        }

      }
    end
  end
end
