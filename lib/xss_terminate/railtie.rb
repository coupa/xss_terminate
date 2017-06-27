if defined?(Rails)
  ::ActiveRecord::Base.include ::XssTerminate::ActiveRecord
end
