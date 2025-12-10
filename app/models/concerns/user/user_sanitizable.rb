module User::UserSanitizable
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_fields
  end

  def password_required?
    new_record? || password.present?
  end

  def normalize_fields
    self.email = email&.downcase&.strip if email.present?
    self.name = name&.strip&.capitalize if name.present?
    self.last_name = last_name&.strip&.capitalize if last_name.present?
  end
end
