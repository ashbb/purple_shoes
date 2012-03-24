require 'rubygems'
require 'rake'
require 'rdoc/task'
require 'rake/clean'
begin
  require 'jeweler'
rescue LoadError
  raise LoadError, "!!! Please install the gem: jeweler !!!"
end

Jeweler::Tasks.new do |gem|
  gem.name = "purple_shoes"
  gem.summary = %Q{Purple Shoes}
  gem.description = %Q{Purple Shoes is one of colorful Shoes, written in JRuby and SWT.}
  gem.email = "ashbbb@gmail.com"
  gem.executables = ["pshoes"]
  gem.homepage = "http://github.com/ashbb/purple_shoes"
  gem.authors = ["ashbb"]
  gem.add_dependency 'swt'
  gem.files = %w[bin lib static samples snapshots].map{|dir| FileList[dir + '/**/*']}.flatten << 'VERSION'
end

Rake::RDocTask.new do |t|
  t.rdoc_dir = 'doc'
  t.title    = 'Purple Shoes'
  t.options << '--charset' << 'utf-8'
  t.rdoc_files.include('README.md')
  t.rdoc_files.include('lib/purple_shoes.rb')
  t.rdoc_files.include('lib/shoes/*.rb')
end

CLEAN.include [ 'pkg', '*.gem', 'doc' ]
