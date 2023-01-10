require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'juwelier'
Juwelier::Tasks.new do |gem|
  gem.name = "rds-rotate-db-snapshots"
  gem.homepage = "http://github.com/serg-kovalev/rds-rotate-db-snapshots"
  gem.license = "MIT"
  gem.summary = %(Amazon RDS DB snapshot rotator)
  gem.description = %(Provides a simple way to rotate RDS DB snapshots with configurable retention periods.)
  gem.email = "kovserg@gmail.com"
  gem.authors = ["Siarhei Kavaliou"]
  gem.version = File.exist?('VERSION') ? File.read('VERSION') : ""
end
Juwelier::RubygemsDotOrgTasks.new

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rds-rotate-db-snapshots #{version}"
  rdoc.rdoc_files.include('README*')
end
