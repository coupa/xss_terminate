require 'rails_sanitize'

module XssTerminate
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unless respond_to?(:xss_terminate_options)
        class_attribute :xss_terminate_options
        self.xss_terminate_options = {
          except: [],
          html5lib_sanitize: [],
          html5lib_options: {},
        }
      end
    end
  end

  module ClassMethods
    def xss_terminate(options = {})
      xss_options = self.xss_terminate_options.dup
      xss_options[:except] = xss_options[:except].dup
      xss_options[:html5lib_sanitize] = xss_options[:html5lib_sanitize].dup
      xss_options[:html5lib_options] = xss_options[:html5lib_options].dup

      xss_options[:except].concat(options[:except] || []).uniq!
      xss_options[:html5lib_sanitize].concat(options[:html5lib_sanitize] || []).uniq!
      xss_options[:html5lib_options].merge!(options[:html5lib_options] || {})

      self.xss_terminate_options = xss_options
    end
  end
  
  module InstanceMethods

    def sanitize_fields
      # fix a bug with Rails internal AR::Base models that get loaded before
      # the plugin, like CGI::Sessions::ActiveRecordStore::Session
      return if xss_terminate_options.nil? || destroyed?
      
      self.class.columns.each do |column|
        next unless (column.type == :string || column.type == :text)
        
        field = column.name.to_sym
        value = self[field]

        next if value.nil? || !value.is_a?(String)
        
        if xss_terminate_options[:except].include?(field)
          next
        elsif xss_terminate_options[:html5lib_sanitize].include?(field)
          self[field] = RailsSanitize.white_list_sanitizer.sanitize(value)
        else
          self[field] = CoupaHelper.coupa_sanitize(value)
        end
      end
      
    end
  end
end

ActiveRecord::Base.send(:include, XssTerminate)
ActiveRecord::Base.before_validation :sanitize_fields
