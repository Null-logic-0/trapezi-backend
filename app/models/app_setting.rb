class AppSetting < ApplicationRecord
  def self.registration_enabled?
    find_by(key: "registration_enabled")&.value == "true"
  end

  def self.maintenance_mode?
    find_by(key: "maintenance_mode")&.value == "true"
  end
end
