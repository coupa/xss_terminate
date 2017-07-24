require 'action_pack/version'
require 'action_view'

module XssTerminate
  # This class exists so including the Rails HTML sanitization helpers doesn't pollute your models.
  class RailsSanitizer
    # Determines if the current Rails version is 2.2 or higher
    def self.rails_2_or_higher
      ::ActionPack::VERSION::MAJOR == 3 || (::ActionPack::VERSION::MAJOR == 2 && ::ActionPack::VERSION::MINOR >= 2)
    end

    if rails_2_or_higher
      extend ::ActionView::Helpers::SanitizeHelper::ClassMethods
    else # Rails 2.1 or earlier (note: xss_terminate does not support Rails 1.x)
      include ::ActionView::Helpers::SanitizeHelper
    end
  end
end
