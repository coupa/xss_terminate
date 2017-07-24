require_relative 'xss_terminate/active_record'
require_relative 'xss_terminate/railtie'
require_relative 'xss_terminate/rails_sanitizer'
require_relative 'xss_terminate/text_sanitizer'

module XssTerminate
  # Configures xss_terminate
  #
  # XssTerminate.configure do |c|
  #   # These are the default options applied to each attribute
  #   c.options = {
  #     if: true,     # Enables xss_terminate by default
  #     as: :text,    # Sanitizes as text by default
  #   }
  #
  #   # This is the sanitizer used for :text
  #   c.text_sanitizer = ...
  #
  #   # This is the sanitizer used for :html
  #   c.html_sanitizer = ...
  # end
  def self.configure
    yield(self.configuration)
  end

  # Returns the current xss_terminate configuration
  def self.configuration
    @configuration ||= OpenStruct.new(
      default_options: {
        if: true,
        as: :text,
      },
      sanitizers: {
        html: ::XssTerminate::RailsSanitizer.white_list_sanitizer,
        text: ::XssTerminate::TextSanitizer.new,
      },
    )
  end
end
