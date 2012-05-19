class Shoes
  class Basic
    include Mod
    def initialize args
      @initials = args
      @hided = true if args[:hidden]
      args.delete :hidden
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end

      (@app.order << self) unless @noorder
      (@app.cslot.contents << self) unless @nocontrol

      @parent = @app.cslot
      
      Basic.class_eval do
        attr_accessor *args.keys
      end

      if @real
        if @real.is_a? Swt::Image
          @width = @full_width if @width.zero?
          @height = @full_height if @height.zero?
        elsif @real.is_a? Symbol
          # do nothing
        else
          @width, @height = @real.getSize.x, @real.getSize.y
        end
      end

      set_margin
      @width += (@margin_left + @margin_right)
      @height += (@margin_top + @margin_bottom)

      [:app, :real].each{|k| args.delete k}
      @args = args
      @dps = []
    end

    attr_reader :args, :initials
    attr_accessor :parent, :pl, :ln, :dps

    def move x, y
      @app.cslot.contents -= [self]
      move3 x, y
      self
    end

    def move2 x, y
      move3 x, y
    end

    def move3 x, y
      unless @app.cs.isDisposed
        @app.cs.redraw @left, @top, @width, @height, false
        @app.cs.redraw x, y, @width, @height, false
      end
      @left, @top = x, y
    end

    def center_at x, y
      [x - (@width / 2), y - (@height / 2)]
    end

    def positioning x, y, max
      if parent.is_a?(Flow) and x + @width <= parent.left + parent.width
        x = @right ? parent.left + parent.width - @width - @right : x + parent.margin_left
        y = max.top + parent.margin_top
        move3 x, y
        max = self if max.height < @height
      else
        x = @right ? parent.left + parent.width - @width - @right : parent.left + parent.margin_left
        y = max.top + max.height + parent.margin_top
        move3 x, y
        max = self
      end
      max
    end

    def clear
      unless @app.cs.isDisposed
        @app.cs.removePaintListener pl if pl
        @app.cs.removeListener Swt::SWT::MouseDown, ln if ln
        @app.cs.removeListener Swt::SWT::MouseUp, ln if ln
        @real.dispose unless @real.is_a? Symbol
        @dps.each{|dp| dp.dispose if dp}
        @dps.clear
        @parent.contents -= [self]
        @app.mscs -= [self]
        @app.mhcs -= [self]
        hide
      end
    end
    
    def show
      @hided = true
      toggle
    end
    
    def hide
      @hided = false
      toggle
    end
    
    def toggle
      @hided = !@hided
      @app.cs.redraw @left, @top, @width, @height, false unless @app.cs.isDisposed
      self
    end
    
    def fix_size
      flag = false
      set_margin
      case self
      when EditBox, Button
        if 0 < @initials[:width] and @initials[:width] <= 1.0
          @width = @parent.width * @initials[:width] - @margin_left - @margin_right
          flag = true
        end
        if 0 < @initials[:height] and @initials[:height] <= 1.0
          @height = @parent.height * @initials[:height] - @margin_top - @margin_bottom
          flag = true
        end
      when EditLine, ListBox
        if 0 < @initials[:width] and @initials[:width] <= 1.0
          @width = @parent.width * @initials[:width] - @margin_left - @margin_right
          @height = 20
          flag = true
        end
      else
      end
      if flag
        @real.setSize @width, @height
        move @left, @top
      end
    end
  end

  class Image < Basic; end

  class Pattern < Basic
    def positioning x, y, max
      self.width = self.height = 0
      super
    end
    def move2 x, y
      @left, @top, @width, @height = parent.left, parent.top, parent.width, parent.height
      @width = @args[:width] unless @args[:width].zero?
      @height = @args[:height] unless @args[:height].zero?
      unless @real
        m = self.class.to_s.downcase[7..-1]
        args = eval "{#{@args.keys.map{|k| "#{k}: @#{k}"}.join(', ')}}"
        args = [@pattern, args.merge({create_real: true, nocontrol: true})]
        pt = @app.send(m, *args)
        @real = pt.real
      end
    end
  end
  class Background < Pattern; end
  class Border < Pattern; end

  class ShapeBase < Basic; end
  class Rect < ShapeBase
    def move3 x, y
      x, y = center_at(x, y) if @center
      super
    end
  end
  class Oval < ShapeBase
    def move3 x, y
      x, y = center_at(x, y) if @center
      super
    end
  end
  class Line < ShapeBase
    def move x, y
      dx, dy = x - @left, y - @top
      @sx += dx; @ex += dx
      @sy += dy; @ey += dy
      super
    end
  end
  class Star < ShapeBase
    def move3 x, y
      unless @app.cs.isDisposed
        w, h = @width + @strokewidth + 1, @height + @strokewidth + 1
        hw, hh = w / 2, h / 2
        @app.cs.redraw @left - hw, @top - hh, w, h, false
        @app.cs.redraw x-hw, y - hh, w, h, false
      end
      @left, @top = x, y
    end
  end
  class Shape < ShapeBase
    def move3 x, y
      unless @app.cs.isDisposed
        real.dispose
      end
      @left, @top = x, y
    end
    def move_to x, y
      real.moveTo x + left, y + top
    end
    def line_to x, y
      real.lineTo x + left, y + top
    end
    def quad_to cx, cy, x, y
      real.quadTo cx + left, cy + top, x + left, y + top
    end
  end
  
  class TextBlock < Basic
    def initialize args
      @links = []
      super
    end
    attr_reader :links
    attr_accessor :cursor, :textcursor
    def text
      @args[:markup]
    end
    def text= s
      style markup: s
    end
    alias :replace :text=
    def positioning x, y, max
      self.text = @args[:markup]
      super.tap{|s| s.height += (@margin_top + @margin_bottom) if s == self}
    end
    def move x, y
      self.text = @args[:markup]
      super
    end
    def clear
      @links.each &:clear
      @links.clear
      super
    end
    def hit x, y
      x -= @left; y -= @top
      h = @real.getLineBounds(0).height
      text.length.times do |n|
        s = @real.getLocation n, false
        e = @real.getLocation n, true
        return n if (s.x..e.x).include?(x) and (s.y..(e.y+h)).include?(y)
      end
      return nil
    end
  end
  class Banner < TextBlock; end
  class Title < TextBlock; end
  class Subtitle < TextBlock; end
  class Tagline < TextBlock; end
  class Caption < TextBlock; end
  class Para < TextBlock; end
  class Inscription < TextBlock; end
  
  class Native < Basic
    def initialize args
      super
      @app.cs.setTabList @app.cs.getTabList.to_a.push(@real)
    end
    def text
      @real.getText unless @real.isDisposed
    end
    def text=(s)
      @real.setText s.to_s unless @real.isDisposed
    end
    def move x, y
      @real.setLocation x, y unless @real.isDisposed
      super
    end
    def move2 x, y
      @real.setLocation x, y unless @real.isDisposed
      super
    end
    def clear
      @real.dispose unless @real.isDisposed
      @parent.contents -= [self]
    end
    def toggle
      @hided = !@hided
      @real.setVisible !@hided unless @real.isDisposed
      self
    end
    def focus
      @real.setFocus
      @app.focus_ele = self
    end
  end

  class Button < Native
    def click &blk
      @real.addSelectionListener do |e|
        self.class == Button ? blk[self] : (blk[self] if @real.getSelection)
      end
    end
  end
  class ToggleButton < Button
    def checked?
      real.getSelection
    end
    def checked=(tof)
      real.setSelection tof
      block.call if tof
    end
  end
  class Radio < ToggleButton; end
  class Check < ToggleButton; end

  class EditLine < Native
    def change &blk
      @real.addModifyListener{|e| blk[self]}
    end
  end
  class EditBox < Native
    def change &blk
      @real.addModifyListener{|e| blk[self]}
    end
  end
  class ListBox < Native
    def change &blk
      @real.addSelectionListener{|e| blk[self]}
    end
  end
  class Progress < Native
    def fraction
      @real.isDisposed ? 0 : real.getSelection / 100.0
    end
    def fraction= n
      real.setSelection n * 100 unless @real.isDisposed
    end
  end
end
