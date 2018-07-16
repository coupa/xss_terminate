require 'active_record'

module XssTerminate
  module ActiveRecord
    def self.included(base)
      base.extend(ClassMethods)
      base.prepend(InstanceMethods)
      base.class_eval do
        unless respond_to?(:xss_terminate_options)
          class_attribute :xss_terminate_options
          self.xss_terminate_options = {}

          after_save :xss_terminate_options_clear
        end
      end
    end

    module ClassMethods
      # * format: :text/:html/Proc. Specifies the sanitizer that will be used. You can configure
      #           the sanitizers from `sanitizers` hash in `XssTerminate.configure`.
      # Examples
      # xss_terminate :no_need, format: :raw
      # xss_terminate :maybe, format: ->(r) do
      #   # r is the ActiveRecord object being manipulated
      #   r.whatever ? :text : :raw
      # end
      # xss_terminate :body, format: :html
      # xss_terminate :text
      def xss_terminate(attributes, options = {})
        Array.wrap(attributes).each do |a|
          a = a.to_sym
          attr_options = xss_terminate_options[a] || ::XssTerminate.configuration.default_options
          attr_options = attr_options.merge(options)
          self.xss_terminate_options = self.xss_terminate_options.merge(a => attr_options)
        end
      end
    end

    module InstanceMethods
      # Added to allow for backwards compatability
      if ::ActiveRecord::AttributeMethods::Write.private_method_defined? :write_attribute_with_type_cast
        # Rails <= 5.0
        def write_attribute_with_type_cast(attr_name, value, should_type_cast)
          super(attr_name, xss_terminate_sanitize(attr_name, value), should_type_cast)
        end
      elsif ::ActiveRecord::AttributeMethods::Write.method_defined? :raw_write_attribute
        # Rails = 5.1
        def raw_write_attribute(attr_name, value)
          super(attr_name, xss_terminate_sanitize(attr_name, value))
        end

        def write_attribute(attr_name, value)
          super(attr_name, xss_terminate_sanitize(attr_name, value))
        end
      elsif ::ActiveRecord::AttributeMethods::Write.private_method_defined? :write_attribute_without_type_cast
        # Rails 5.2
        def write_attribute_without_type_cast(attr_name, value)
          super(attr_name, xss_terminate_sanitize(attr_name, value))
        end

        def _write_attribute(attr_name, value)
          super(attr_name, xss_terminate_sanitize(attr_name, value))
        end
      else
        # Unknown Rails
        raise NotImplementedError, "Expected methods not found, unknown Rails version. Please check gemspec"
      end

      # Sanitized value for using the options for attr_name
      def xss_terminate_sanitize(attr_name, value)
        if !value.nil? && value.is_a?(String)
          opts = @xss_terminate_options_override || xss_terminate_options_for(attr_name)
          if sanitizer = Formats[opts[:format]].sanitizer
            format_options_key = "#{opts[:format]}_options".to_sym
            value = if opts.has_key?(format_options_key)
              sanitizer.sanitize(value, opts[format_options_key])
            else
              sanitizer.sanitize(value)
            end
          end
        end
        value
      end

      # Overrides xss_terminate options
      def with_xss_terminate_options(options)
         original = @xss_terminate_options_override
         begin
           @xss_terminate_options_override = options
           yield
         ensure
           @xss_terminate_options_override = original
         end
      end

      # Retrieves xss_terminate options for the specified attribute
      # Since this method is called on an attribute-by-attribute basis, we use a cache of the options
      def xss_terminate_options_for(attribute)
        # The @xss_terminate_options_cache is keyed using symbols
        attribute = attribute.to_sym

        # Check if we have a cache of the evaluated options
        return @xss_terminate_options_cache[attribute] if @xss_terminate_options_cache&.has_key?(attribute)

        # There is no cache for the options
        h = self.class.xss_terminate_options[attribute.to_sym]
        h ||= ::XssTerminate.configuration.default_options

        # Let's get a copy because we are going to replace the Procs with evaluated values
        h = h.dup

        # Process keys
        h.each do |k, v|
          h[k] = xss_terminate_evaluate_option(v)
        end

        @xss_terminate_options_cache ||= {}
        @xss_terminate_options_cache[attribute] = h
      end

      # Clears the xss_terminate_options cache.
      # The cache is also cleared automatically when the object is saved.
      def xss_terminate_options_clear(attribute = nil)
        if attribute
          @xss_terminate_options_cache&.delete(attribute)
        else
          @xss_terminate_options_cache = nil
        end
      end

      protected
      # Evaluate an xss_terminate_option
      def xss_terminate_evaluate_option(v)
        if v.is_a?(Proc)
          v.call(self)
        else
          v
        end
      end
    end
  end
end
