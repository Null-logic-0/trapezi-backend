class FoodPlace < ApplicationRecord
  belongs_to :user

  has_many_attached :images
  has_one_attached :menu_pdf

  enum :category, {
    restaurant: "restaurant",
    cafe: "cafe",
    bar: "bar",
    bakery: "bakery",
    pastry: "pastry"
  }

  validates :business_name, :address, :category, :working_schedule, presence: true

  geocoded_by :address

  after_validation :geocode, if: :will_save_change_to_address?

  def working_schedule_readable
    (working_schedule || {}).map do |k, v|
      "#{k.to_s.humanize} #{v['from'] || 'Closed'}-#{v['to'] || 'Closed'}"
    end.join(", ")
  end

  private

  def validate_working_schedule_format
    if working_schedule.blank? || !working_schedule.is_a?(Hash)
      errors.add(:working_schedule, "must be a hash with per-day schedule")
      return
    end

    working_schedule&.each do |day, times|
      unless times.is_a?(Hash) && times.key?("from") && times.key?("to")
        errors.add(:working_schedule, "#{day} must have 'from' and 'to' keys (can be null)")
        next
      end

      from = times["from"]
      to = times["to"]
      next if from.blank? && to.blank?

      unless from =~ /\A\d{2}:\d{2}\z/ && to =~ /\A\d{2}:\d{2}\z/
        errors.add(:working_schedule, "#{day}: times must be in HH:MM")
        next
      end

      if from >= to
        errors.add(:working_schedule, "#{day}: closing time must be after opening time")
      end
    end
  end

  def validate_images
    unless images.attached?
      errors.add(:images, "must be attach an image!")
      return
    end

    if images.count > 5
      errors.add(:images, "maximum 5 images allowed")
    end

    images.each do |img|
      unless img.content_type.in?(%w[image/jpeg image/png image/jpg])
        errors.add(:images, "must be JPEG or PNG")
      end
    end
  end

  def validate_menu_pdf
    return unless menu_pdf.attached?
    unless menu_pdf.content_type == "application/pdf"
      errors.add(:menu_pdf, "must be a PDF file")
    end
  end
end
