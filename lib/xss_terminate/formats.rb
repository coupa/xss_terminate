module XssTerminate
  module Formats
    extend ActiveSupport::Autoload
    
    autoload :Html
    autoload :Text
    autoload :Raw
    
    class <<self
      def lookup(format)
        s_class = const_get(format.to_s.camelize)
      end
    end
  end
end
