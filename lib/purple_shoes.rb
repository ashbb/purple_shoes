require 'tmpdir'
require 'pathname'
require 'java'
require 'swt'

STDOUT.sync = true

Types = module Shoes; self end

module Shoes
  DIR = Pathname.new(__FILE__).realpath.dirname.to_s
end

class Object
  remove_const :Shoes
end

require_relative 'shoes/ruby'
require_relative 'shoes/main'
require_relative 'shoes/app'
