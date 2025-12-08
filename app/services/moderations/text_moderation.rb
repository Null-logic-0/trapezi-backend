require "cld3"
require_relative "georgian_blacklist"
module Moderations
  class TextModeration
    def self.check?(text)
      return false if text.blank?

      return true if flagged_by_georgian_list?(text)

      flagged_by_ai?(text)
    rescue StandardError => e
      Rails.logger.error("[TextModeration Error] #{e.message}")
      false
    end

    private_class_method

    def self.flagged_by_georgian_list?(text)
      GeorgianBlacklist::WORDS.any? { |word| text.include?(word) }
    end

    def self.flagged_by_ai?(text)
      response = OpenAIClient.moderations(
        parameters: {
          model: "omni-moderation-latest",
          input: text
        }
      )
      result = response["results"].first
      result["flagged"] == true
    end
  end
end
