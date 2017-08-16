module XssTerminate
  module Formats
    class AbstractFormat
      class <<self
        def sanitizer
          raise NotImplementedError, "Formats must implement sanitizer"
        end

        delegate :sanitize, to: :sanitizer
      end
    end
  end
end

