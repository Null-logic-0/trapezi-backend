settings = [
  { key: "maintenance_mode", value: "false" },
  { key: "registration_enabled", value: "true" }
]

settings.each do |attrs|
  setting = AppSetting.find_or_initialize_by(key: attrs[:key])
  setting.assign_attributes(attrs)
  setting.save!
end
