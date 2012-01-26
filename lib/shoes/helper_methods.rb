class Shoes
  module Mod
    def set_margin
      @margin ||= [0, 0, 0, 0]
      @margin = [@margin, @margin, @margin, @margin] if @margin.is_a? Integer
      margin_left, margin_top, margin_right, margin_bottom = @margin
      @margin_left ||= margin_left
      @margin_top ||= margin_top
      @margin_right ||= margin_right
      @margin_bottom ||= margin_bottom
    end

    attr_reader :margin_left, :margin_top, :margin_right, :margin_bottom
  end
  
  module Mod2
    def init_app_vars
      @contents, @order = [], []
    end
  end
  
  class App
    def basic_attributes args={}
      default = BASIC_ATTRIBUTES_DEFAULT
      default.merge!({nocontrol: true}) if @nolayout
      replace_string_to_float args
      default.merge args
    end

    def slot_attributes args={}
      default = SLOT_ATTRIBUTES_DEFAULT
      replace_string_to_float args
      default.merge args
    end
    
    def replace_string_to_float args={}
      [:width, :height, :left, :top].each do |k|
        if args[k].is_a? String
          args[k] = args[k].include?('%') ? args[k].to_f / 100 : args[k].to_i
        end
      end
    end
  end
  
  def self.contents_alignment slot
    x, y = slot.left.to_i, slot.top.to_i
    max = Struct.new(:top, :height).new
    max.top, max.height = y, 0
    slot_height = 0

    slot.contents.each do |ele|
      tmp = max
      max, flag = ele.positioning x, y, max
      x, y = ele.left + ele.width, ele.top + ele.height
      unless max == tmp
        slot_height = flag && !slot_height.zero? ? y : slot_height + max.height
      end
    end
    slot_height
  end
  
  def self.repaint_all slot
    slot.contents.each do |ele|
      ele.is_a?(Basic) ? ele.move2(ele.left + ele.margin_left, ele.top + ele.margin_top) : repaint_all(ele)
    end
  end
  
  def self.call_back_procs app
    init_contents app.cslot.contents
    app.cslot.width, app.cslot.height = app.width, app.height
    scrollable_height = contents_alignment app.cslot
    repaint_all app.cslot
  end
  
  def self.init_contents contents
    contents.each do |ele|
      next unless ele.is_a? Slot
      ele.initials.each do |k, v|
        ele.send "#{k}=", v
      end
    end
  end
end
