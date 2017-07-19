require 'rails/html/sanitizer'

module XssTerminate
  module Formats
    class Html
      class <<self
        def sanitizer
          @sanitizer ||= ::Rails::Html::WhiteListSanitizer.new
        end
      end
    end
  end
end
