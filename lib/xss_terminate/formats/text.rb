require_relative 'abstract_format'
require 'xss_terminate/sanitizers/text'

module XssTerminate
  module Formats
    class Text < AbstractFormat
      class <<self
        def sanitizer
          @sanitizer ||= ::XssTerminate::Sanitizers::Text.new
        end
      end
    end
  end
end

