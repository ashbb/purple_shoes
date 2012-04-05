require 'tmpdir'
require 'pathname'
require 'java'
require 'swt'

STDOUT.sync = true

Types = module Shoes; self end

module Shoes
  DIR = Pathname.new(__FILE__).realpath.dirname.to_s
  FONTS = []
  BANNER_DEFAULT, TITLE_DEFAULT, SUBTITLE_DEFAULT, TAGLINE_DEFAULT, CAPTION_DEFAULT, PARA_DEFAULT, INSCRIPTION_DEFAULT = 
    {}, {}, {}, {}, {}, {}, {}
  SHOES_VERSION = IO.read(File.join(DIR, '../VERSION')).chomp
  BASIC_ATTRIBUTES_DEFAULT = {left: 0, top: 0, width: 0, height: 0, angle: 0, curve: 0}
  SLOT_ATTRIBUTES_DEFAULT = {left: nil, top: nil, width: 1.0, height: 0}
  
  KEY_NAMES = {}
  %w[DEL ESC ALT SHIFT CTRL ARROW_UP ARROW_DOWN ARROW_LEFT ARROW_RIGHT 
    PAGE_UP PAGE_DOWN HOME END INSERT 
    F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13 F14 F15].each{|k| KEY_NAMES[eval("Swt::SWT::#{k}")] = k}
  KEY_NAMES[Swt::SWT::CR] = "\n"
  COLORS = {}
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
require_relative 'shoes/colors'
require_relative 'shoes/basic'
require_relative 'shoes/main'
require_relative 'shoes/app'
require_relative 'shoes/anim'
require_relative 'shoes/slot'
require_relative 'shoes/text'
require_relative 'shoes/widget'
require_relative 'shoes/url'
require_relative 'shoes/style'
require_relative 'shoes/download'
require_relative 'shoes/manual'

require_relative 'plugins/video'
