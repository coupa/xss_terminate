module XssTerminate
  module Formats
    class Raw
      class <<self
        def sanitizer
          nil
        end
      end
    end
  end
end

