module AttachmentUrl
  extend ActiveSupport::Concern

  def file_url(attachment)
    return unless attachment.attached?
    if Rails.env.production?
      bucket = ENV.fetch("AWS_BUCKET_URL")
      "#{bucket}/#{attachment}"
    else
      Rails.application.routes.url_helpers.url_for(attachment)
    end
  end

  def files_url(attachments)
    return unless attachments.attached?

    attachments.map do |a|
      if Rails.env.production?
        bucket = ENV.fetch("AWS_BUCKET_URL")
        "#{bucket}/#{a.key}"
      else
        Rails.application.routes.url_helpers.url_for(a)
      end
    end
  end
end
