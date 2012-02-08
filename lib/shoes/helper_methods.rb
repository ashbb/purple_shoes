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

    def click &blk
      @app.clickable self, :click, &blk
    end
    
    def release &blk
      @app.clickable self, :release, &blk
    end

    attr_reader :margin_left, :margin_top, :margin_right, :margin_bottom
  end
  
  module Mod2
    def init_app_vars
      @contents, @mmcs, @order = [], [], []
      @mouse_button, @mouse_pos = 0, [0, 0]
      @fill, @stroke = black, black
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
    
    def clickable s, flag = :click, &blk
      if blk
        ln = Swt::Listener.new
        class << ln; self end.
        instance_eval do
          define_method :handleEvent do |e|
            blk[s] if s.left <= e.x and e.x <= s.left + s.width and s.top <= e.y and e.y <= s.top + s.height
          end
        end
        @shell.addListener Swt::SWT::MouseDown, ln if flag == :click
        @shell.addListener Swt::SWT::MouseUp, ln if flag == :release
      end
    end

    def get_styles msg, styles=[], spoint=0
      msg.each do |e|
        if e.is_a? Text
          epoint = spoint + e.to_s.length - 1
          styles << [e.style, spoint..epoint, e.color]
          get_styles e.str, styles, spoint
        end
        spoint += e.to_s.length
      end
      styles
    end
    
    def set_styles tl, args
      font = Swt::Font.new Shoes.display, args[:font], args[:size], Swt::SWT::NORMAL
      fgc = Swt::Color.new Shoes.display, *args[:stroke]
      bgc = args[:fill] ? Swt::Color.new(Shoes.display, *args[:fill]) : nil
      style = Swt::TextStyle.new font, fgc, bgc
      tl.setStyle style, 0, args[:markup].length - 1
      
      args[:styles].each do |s|
        font, ft, fg, bg, cmds, small = args[:font], Swt::SWT::NORMAL, fgc, bgc, [], 1
        nested_styles(args[:styles], s).each do |e|
          case e[0]
          when :strong
            ft = ft | Swt::SWT::BOLD
          when :em
            ft = ft | Swt::SWT::ITALIC 
          when :fg
            fg = Swt::Color.new Shoes.display, *e[2][0,3]
          when :bg
            bg = Swt::Color.new Shoes.display, *e[2][0,3]
          when :ins
            cmds << "underline = true"
          when :del
            cmds << "strikeout = true"
          when :sub
            small *= 0.8
            cmds << "rise = -5"
          when :sup
            small *= 0.8
            cmds << "rise = 5"
          when :code
            font = "Lucida Console"
          else
          end
        end
        ft = Swt::Font.new Shoes.display, font, args[:size]*small, ft
        style = Swt::TextStyle.new ft, fg, bg
        cmds.each do |cmd|
          eval "style.#{cmd}"
        end
        tl.setStyle style, s[1].first, s[1].last
      end if args[:styles]
    end
    
    def nested_styles styles, s
      styles.map do |e|
        (e[1].first <= s[1].first and s[1].last <= e[1].last) ? e : nil
      end - [nil]
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

  def self.mouse_motion_control app
    app.mmcs.each{|blk| blk[*app.mouse_pos]}
  end
end
