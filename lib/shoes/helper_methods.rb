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

    def hided
      @app.hided or @hided
    end

    def click &blk
      @app.clickable self, :click, &blk
    end
    
    def release &blk
      @app.clickable self, :release, &blk
    end

    def hover &blk
      @hover_proc = blk
      (@app.mhcs << self) unless @app.mhcs.include? self
    end

    def leave &blk
      @leave_proc = blk
      (@app.mhcs << self) unless @app.mhcs.include? self
    end

    attr_reader :margin_left, :margin_top, :margin_right, :margin_bottom, :hover_proc, :leave_proc
    attr_accessor :hovered
  end
  
  module Mod2
    def init_app_vars
      @contents, @mmcs, @mscs, @mhcs, @order = [], [], [], [], []
      @location = '/'
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
        s.ln = ln
        @mscs << s
        class << ln; self end.
        instance_eval do
          define_method :handleEvent do |e|
            mb, mx, my = e.button, e.x, e.y
            if s.is_a?(Link) and !s.parent.hided
              blk[mb, mx, my] if ((s.pl..(s.pl+s.pw)).include?(mx) and (s.sy..s.ey).include?(my) and !((s.pl..s.sx).include?(mx) and (s.sy..(s.sy+s.lh)).include?(my)) and !((s.ex..(s.pl+s.pw)).include?(mx) and ((s.ey-s.lh)..s.ey).include?(my)))
            elsif !s.is_a?(Link) and !s.hided
              dx, dy = s.is_a?(Star) ? [s.width / 2.0, s.height / 2.0] : [0, 0]
              blk[mb, mx, my] if s.left - dx <= mx and mx <= s.left - dx + s.width and s.top - dy <= my and my <= s.top - dy + s.height
            end
          end
        end
        @cs.addListener Swt::SWT::MouseDown, ln if flag == :click
        @cs.addListener Swt::SWT::MouseUp, ln if flag == :release
      end
    end

    def get_styles msg, styles=[], spoint=0
      msg.each do |e|
        if e.is_a? Text
          epoint = spoint + e.to_s.length - 1
          styles << [e, spoint..epoint]
          get_styles e.str, styles, spoint
        end
        spoint += e.to_s.length
      end
      styles
    end
    
    def set_styles s, args
      tl = s.real
      tl.setJustify args[:justify]
      tl.setSpacing(args[:leading] || 4)
      tl.setAlignment case args[:align]
        when 'center'; Swt::SWT::CENTER
        when 'right'; Swt::SWT::RIGHT
        else Swt::SWT::LEFT
        end
      font = Swt::Font.new Shoes.display, args[:font], args[:size], Swt::SWT::NORMAL
      fgc = Swt::Color.new Shoes.display, *args[:stroke]
      bgc = args[:fill] ? Swt::Color.new(Shoes.display, *args[:fill]) : nil
      style = Swt::TextStyle.new font, fgc, bgc
      tl.setStyle style, 0, args[:markup].length - 1
      s.dps << font << fgc << bgc
      
      args[:styles].each do |st|
        font, ft, fg, bg, cmds, small = args[:font], Swt::SWT::NORMAL, fgc, bgc, [], 1
        nested_styles(args[:styles], st).each do |e|
          case e[0].style
          when :strong
            ft = ft | Swt::SWT::BOLD
          when :em
            ft = ft | Swt::SWT::ITALIC 
          when :fg
            fg = Swt::Color.new Shoes.display, *e[0].color[0,3]
          when :bg
            bg = Swt::Color.new Shoes.display, *e[0].color[0,3]
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
          when :link
            (cmds << "underline = true") if LINK_DEFAULT[:underline]
            fg = Swt::Color.new Shoes.display, *blue
            spos = tl.getLocation e[1].first, false
            epos = tl.getLocation e[1].last, true
            e[0].lh = tl.getLineBounds(0).height
            e[0].sx, e[0].sy = s.left + spos.x, s.top + spos.y
            e[0].ex, e[0].ey = s.left + epos.x, s.top + epos.y + e[0].lh
            e[0].pl, e[0].pt, e[0].pw, e[0].ph = s.left, s.top, s.width, s.height
            s.links << e[0]
            unless e[0].clickabled
              e[0].parent = s
              clickable e[0], &e[0].blk
              e[0].clickabled = true
            end
          else
          end
        end
        ft = Swt::Font.new Shoes.display, font, args[:size]*small, ft
        style = Swt::TextStyle.new ft, fg, bg
        cmds.each do |cmd|
          eval "style.#{cmd}"
        end
        tl.setStyle style, st[1].first, st[1].last
        s.dps << ft
      end if args[:styles]
    end
    
    def nested_styles styles, st
      styles.map do |e|
        (e[1].first <= st[1].first and st[1].last <= e[1].last) ? e : nil
      end - [nil]
    end

    def pattern_pos left, top, w, h, a
      w, h = w*0.5, h*0.5
      a = Math::PI*(a/180.0)
      a = a % (Math::PI*2.0)
      cal = proc do
        l = Math.sqrt(w**2 + h**2)
        b = Math.atan(h/w)
        c = Math::PI*0.5 - a - b
        r = l * Math.cos(c.abs)
        [r * Math.cos(b+c), r * Math.sin(b+c)]
      end
      if 0 <= a and a < Math::PI*0.5
        x, y = cal.call
        [left+w+x, top+h-y, left+w-x, top+h+y]
      elsif Math::PI*0.5 <= a and a < Math::PI
        a -= Math::PI*0.5
        w, h = h, w
        x, y = cal.call
        [left+h+y, top+w+x, left+h-y, top+w-x]
      elsif Math::PI <= a and a < Math::PI*1.5
        a -= Math::PI
        x, y = cal.call
        [left+w-x, top+h+y, left+w+x, top+h-y]
      elsif Math::PI*1.5 <= a and a < Math::PI*2.0
        a -= Math::PI*1.5
        w, h = h, w
        x, y = cal.call
        [left+h-y, top+w-x, left+h+y, top+w+x]
      end
    end
  end
  
  def self.contents_alignment slot
    x, y = slot.left.to_i, slot.top.to_i
    max = Struct.new(:top, :height).new
    max.top, max.height = y, 0
    slot_height, slot_top = 0, y

    slot.contents.each do |ele|
      tmp = max
      max = ele.positioning x, y, max
      x, y = ele.left + ele.width, ele.top + ele.height
      unless max == tmp
        slot_height = max.top + max.height - slot_top
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
    w, h = app.width, app.height
    app.cslot.width, app.cslot.height = w, h
    scrollable_height = contents_alignment app.cslot
    app.cs.setSize w, [scrollable_height, h].max
    vb = app.shell.getVerticalBar
    vb.setVisible(scrollable_height > h)
    if scrollable_height > h
      vb.setThumb h * h / scrollable_height
      vb.setMaximum scrollable_height - h + vb.getThumb
      vb.setIncrement h / 2
    else
      location = app.cs.getLocation
      location.y = 0
      app.cs.setLocation location
    end
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
  
  def self.mouse_hover_control app
    app.mhcs.each do |e|
      if mouse_on?(e) and !e.hovered
        e.hovered = true
        e.hover_proc[e] if e.hover_proc
      end
    end
  end

  def self.mouse_leave_control app
    app.mhcs.each do |e|
      if !mouse_on?(e) and e.hovered
        e.hovered = false
        e.leave_proc[e] if e.leave_proc
      end
    end
  end
  
  def self.mouse_on? e
    mb, mx, my = e.app.mouse
    dx, dy = e.is_a?(Star) ? [e.width / 2.0, e.height / 2.0] : [0, 0]
    e.left - dx <= mx and mx <= e.left - dx + e.width and e.top - dy <= my and my <= e.top - dy + e.height
  end

  def self.mouse_shape_control app
    flag = false
    mouse_x, mouse_y = app.mouse_pos
    app.mscs.each do |s|
      if s.is_a?(Link) and !s.parent.hided
        flag = true if ((s.pl..(s.pl+s.pw)).include?(mouse_x) and (s.sy..s.ey).include?(mouse_y) and !((s.pl..s.sx).include?(mouse_x) and (s.sy..(s.sy+s.lh)).include?(mouse_y)) and !((s.ex..(s.pl+s.pw)).include?(mouse_x) and ((s.ey-s.lh)..s.ey).include?(mouse_y)))
      elsif !s.is_a?(Link) and !s.hided
        dx, dy = s.is_a?(Star) ? [s.width / 2.0, s.height / 2.0] : [0, 0]
        flag = true if s.left - dx <= mouse_x and mouse_x <= s.left - dx + s.width and s.top - dy <= mouse_y and mouse_y <= s.top - dy + s.height
      end
    end
    cursor = flag ? Swt::SWT::CURSOR_HAND : Swt::SWT::CURSOR_ARROW
    app.shell.setCursor  Shoes.display.getSystemCursor(cursor)
  end

  def self.set_pattern s, gc, pat, m = :Background
    pat = s.app.tr_color(pat) if pat.is_a? String
    if pat.is_a? Array
      eval "gc.set#{m} Swt::Color.new(Shoes.display, *pat[0,3])"
      gc.setAlpha(pat[3] ? pat[3]*255 : 255)
    elsif pat.is_a? Range
      if s.is_a? Star
        eval "gc.set#{m}Pattern s.app.gradient(pat, s.left-s.width/2.0, s.top-s.height/2.0, s.width, s.height, s.angle)"
      else
        eval "gc.set#{m}Pattern s.app.gradient(pat, s.left, s.top, s.width, s.height, s.angle)"
      end
    elsif pat.is_a? String
      eval "gc.set#{m}Pattern Swt::Pattern.new(Shoes.display, Swt::Image.new(Shoes.display, pat))"
    end
  end
  
  def self.set_rotate gc, angle, left, top
    if block_given?
      tr = Swt::Transform.new Shoes.display
      reset_rotate tr, gc, angle, left, top
      yield
      reset_rotate tr, gc, -angle, left, top
    end
  end
    
  def self.reset_rotate tr, gc, angle, left, top
    tr.translate left, top
    tr.rotate angle
    tr.translate -left, -top
    gc.setTransform tr
  end

  def self.dps_reset dps, gc
    dps.each{|dp| dp.dispose if dp}
    dps.clear
    dps << gc
  end
end
