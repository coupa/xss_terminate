# This file needs to be first

require 'bundler/setup'
Bundler.setup

require 'byebug'
require 'rails/all'
Bundler.require(:default, :test)

# set up test environment
require 'test/unit'
require 'xss_terminate'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

# load test schema
load(File.dirname(__FILE__) + "/schema.rb")

# load test models

require File.join(File.dirname(__FILE__), 'models/child_entry')
require File.join(File.dirname(__FILE__), 'models/comment')
require File.join(File.dirname(__FILE__), 'models/entry')
require File.join(File.dirname(__FILE__), 'models/group')
require File.join(File.dirname(__FILE__), 'models/message')
require File.join(File.dirname(__FILE__), 'models/person')
