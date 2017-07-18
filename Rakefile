require 'rake/testtask'

desc 'Test the xss_terminate plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

task :console => :environment do
  require 'irb'
  require 'byebug'
  ARGV.clear
  IRB.start
end

task :environment do
  require 'bundler/setup'
  Bundler.setup
  Bundler.require(:default, :test)
end

desc 'By default, run the unit tests'
task :default => :test
