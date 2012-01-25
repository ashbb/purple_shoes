require 'tmpdir'
require 'pathname'
require 'java'
require 'swt'

STDOUT.sync = true

Types = module Shoes; self end

module Shoes
  DIR = Pathname.new(__FILE__).realpath.dirname.to_s
end

module Swt
  include_package 'org.eclipse.swt'
  include_package 'org.eclipse.swt.layout'
  include_package 'org.eclipse.swt.widgets'
  include_package 'org.eclipse.swt.graphics'
  include_package 'org.eclipse.swt.events'
end

class Object
  remove_const :Shoes
end

require_relative 'shoes/ruby'
require_relative 'shoes/helper_methods'
require_relative 'shoes/main'
require_relative 'shoes/app'
require_relative 'shoes/anim'