require 'rake/testtask'

desc 'Test the xss_terminate plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

task :console => :test_environment do
  require 'irb'
  require 'byebug'
  ARGV.clear
  IRB.start
end

task :environment do
  require 'bundler/setup'
  Bundler.setup
end

task :test_environment => :environment do
  $:.unshift File.dirname(__FILE__) + "/test"
  require '_setup_test'
end

desc 'By default, run the unit tests'
task :default => :test
