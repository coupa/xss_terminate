module XssTerminate
  module ActiveRecord
    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
      base.class_eval do
        unless respond_to?(:xss_terminate_options)
          class_attribute :xss_terminate_options
          self.xss_terminate_options = {}

          before_validation :xss_terminate_sanitize_fields
        end
      end
    end

    module ClassMethods
      # * if: true/false. Does not support procs at the moment
      # Examples
      # xss_terminate :no_need, if: false
      # xss_terminate :body, as: :html
      # xss_terminate :text
      def xss_terminate(attributes, options = {})
        Array.wrap(attributes).each do |a|
          attr_options = xss_terminate_options_for(a).merge(options)
          # Evaluate if
          if attr_options[:if] == false
            # Disable for this attribute
            attr_options = {}
          end
          self.xss_terminate_options = self.xss_terminate_options.merge(a => attr_options)
        end
      end

      # Retrieves xss_terminate options for the specified attribute
      def xss_terminate_options_for(attribute)
        h = self.xss_terminate_options[attribute]
        h || ::XssTerminate.configuration.default_options
      end
    end

    module InstanceMethods
      def xss_terminate_sanitize_fields
        # fix a bug with Rails internal AR::Base models that get loaded before
        # the plugin, like CGI::Sessions::ActiveRecordStore::Session
        return if destroyed?

        sanitizers = ::XssTerminate.configuration.sanitizers
        
        self.class.columns.each do |column|
          next unless (column.type == :string || column.type == :text)

          field = column.name.to_sym
          value = self.send(field)

          next if value.nil? || !value.is_a?(String)

          opts = self.class.xss_terminate_options_for(field)
          sanitizer = sanitizers[opts[:as]]
          if sanitizer
            self.send("#{field}=", sanitizer.sanitize(value))
          end
        end
      end
    end
  end
end
