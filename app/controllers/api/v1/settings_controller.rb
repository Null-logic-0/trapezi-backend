class Api::V1::SettingsController < ApplicationController
  before_action :admin?

  def update_registration
    unless params.key?(:enabled)
      return render json: { success: false, error: "enabled parameter missing" }, status: :unprocessable_entity
    end

    setting = AppSetting.find_or_create_by(key: "registration_enabled")
    setting.update!(value: params[:enabled].to_s)

    render json: { success: true, enabled: ActiveModel::Type::Boolean.new.cast(setting.value) }
  end

  def get_registration
    setting = AppSetting.find_by(key: "registration_enabled")
    enabled = setting.present? ? ActiveModel::Type::Boolean.new.cast(setting.value) : false

    render json: { success: true, enabled: enabled }
  end

  def update_maintenance_mode
    unless params.key?(:enabled)
      return render json: { success: false, error: "enabled parameter missing" }, status: 422
    end

    setting = AppSetting.find_or_create_by(key: "maintenance_mode")
    setting.update!(value: params[:enabled].to_s)

    render json: { success: true, maintenance_mode: ActiveModel::Type::Boolean.new.cast(setting.value) }
  end

  def maintenance_mode
    setting = AppSetting.find_by(key: "maintenance_mode")
    enabled = setting.present? ? ActiveModel::Type::Boolean.new.cast(setting.value) : false

    render json: { success: true, maintenance_mode: enabled }
  end
end
