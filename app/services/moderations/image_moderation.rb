require "google/cloud/vision"

module Moderations
  class ImageModeration
    CHECK_CATEGORIES = %i[adult racy violence nudity].freeze

    LIKELIHOOD_THRESHOLDS = %i[LIKELY VERY_LIKELY].freeze

    def self.any_nsfw?(images)
      Array(images).compact.any? { |img| nsfw?(img) }
    end

    def self.nsfw?(image_input)
      path_to_scan = get_file_path(image_input)

      return false unless path_to_scan

      response = client.safe_search_detection(image: path_to_scan)

      annotation = response.responses.first

      unless annotation
        Rails.logger.error("[NSFW] No response from Google Vision for #{filename(image_input)}")
        return false
      end

      if annotation.error&.message
        Rails.logger.error("[NSFW] API Error: #{annotation.error.message}")
        return false
      end

      safe_search = annotation.safe_search_annotation

      flagged = CHECK_CATEGORIES.any? do |category|
        likelihood = safe_search.public_send(category)
        is_hit = LIKELIHOOD_THRESHOLDS.include?(likelihood)

        if is_hit
          Rails.logger.info("[NSFW] Flagged #{category}: #{likelihood} for #{filename(image_input)}")
        end

        is_hit
      end

      flagged
    rescue => e
      Rails.logger.error("[NSFW] Exception checking image: #{e.message}")
      false
    ensure
      cleanup_file(image_input)
    end

    private

    def self.client
      @client ||= Google::Cloud::Vision.image_annotator
    end

    def self.get_file_path(image_input)
      case image_input
      when ActiveStorage::Attachment, ActiveStorage::Blob

        if image_input.respond_to?(:open)

          @temp_blob = image_input.open
          @temp_blob.path
        else
          image_input.service.send(:path_for, image_input.key)
        end
      when ActionDispatch::Http::UploadedFile
        image_input.tempfile.path
      when String
        image_input
      else
        Rails.logger.error("[NSFW] Unsupported image type: #{image_input.class}")
        nil
      end
    end

    def self.cleanup_file(image_input)
      @temp_blob&.close if defined?(@temp_blob)
    end

    def self.filename(image_input)
      if image_input.respond_to?(:filename)
        image_input.filename.to_s
      elsif image_input.respond_to?(:original_filename)
        image_input.original_filename
      else
        "unknown_file"
      end
    end
  end
end
