module ErrorFormatter
  extend ActiveSupport::Concern

  class_methods do
    def format_errors(record)
      record.errors.messages.transform_values { |msgs| msgs.map(&:to_s).uniq }
    end
  end
end
