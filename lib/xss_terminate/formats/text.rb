require 'xss_terminate/sanitizers/text'

module XssTerminate
  module Formats
    class Text
      class <<self
        def sanitizer
          @sanitizer ||= ::XssTerminate::Sanitizers::Text.new
        end
      end
    end
  end
end

