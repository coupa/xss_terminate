# Rails HTML sanitization on some fields
class Entry < ActiveRecord::Base
  belongs_to :person
  has_many :comments
  
  xss_terminate :html5lib_sanitize => [:body, :extended]
end
