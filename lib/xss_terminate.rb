require_relative 'xss_terminate/active_record'
require_relative 'xss_terminate/formats'
require_relative 'xss_terminate/railtie'

module XssTerminate
  # Configures xss_terminate
  #
  # XssTerminate.configure do |c|
  #   # These are the default options applied to each attribute
  #   c.options = {
  #     format: :text,     # Enables xss_terminate by default
  #   }
  # end
  def self.configure
    yield(self.configuration)
  end

  # Returns the current xss_terminate configuration
  def self.configuration
    @configuration ||= OpenStruct.new(
      default_options: {
        format: :text,
      },
    )
  end
end
