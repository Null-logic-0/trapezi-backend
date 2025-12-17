module FoodPlaces
  class ParamsService
    def self.build(params)
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
        :identification_code,
        :document_pdf,
        :working_schedule,
        :vip_plan,
        :is_vip,
        images: [],

      )

      if permitted[:working_schedule].is_a?(String)
        permitted[:working_schedule] = JSON.parse(permitted[:working_schedule]) rescue {}
      end

      permitted
    end
  end
end
