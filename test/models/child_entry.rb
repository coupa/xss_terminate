require_relative 'entry'

# Overrides xss_terminate options of :body only
class ChildEntry < Entry
  attr_writer :body_format

  def body_format
    @body_format.nil? ? :text : @body_format
  end

  xss_terminate :body, format: ->(r) { r.body_format }
end
