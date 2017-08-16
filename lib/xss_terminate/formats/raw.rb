module XssTerminate
  module Formats
    class Raw < AbstractFormat
      class <<self
        def sanitizer
          nil
        end

        def sanitize(text, options = nil)
          text
        end
      end
    end
  end
end

