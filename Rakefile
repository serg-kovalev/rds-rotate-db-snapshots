require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "rds-rotate-db-snapshots"
  gem.homepage = "http://github.com/serg-kovalev/rds-rotate-db-snapshots"
  gem.license = "MIT"
  gem.summary = %Q{Amazon RDS DB snapshot rotator}
  gem.description = %Q{Provides a simple way to rotate RDS DB snapshots with configurable retention periods.}
  gem.email = "kovserg@gmail.com"
  gem.authors = ["Siarhei Kavaliou"]
  gem.version = File.exist?('VERSION') ? File.read('VERSION') : ""
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

# require 'simplecov'
# Rcov::RcovTask.new do |test|
#   test.libs << 'test'
#   test.pattern = 'test/**/test_*.rb'
#   test.verbose = true
# end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rds-rotate-db-snapshots #{version}"
  rdoc.rdoc_files.include('README*')
end
