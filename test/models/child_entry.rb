require_relative 'entry'

# Overrides xss_terminate options of :body only
class ChildEntry < Entry
  xss_terminate :body, as: :text
end
