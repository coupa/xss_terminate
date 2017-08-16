require_relative 'abstract_format'
require 'rails/html/sanitizer'

module XssTerminate
  module Formats
    class Html < AbstractFormat
      class <<self
        def sanitizer
          @sanitizer ||= ::Rails::Html::WhiteListSanitizer.new
        end
      end
    end
  end
end
