class Shoes
  class Basic
    include Mod
    def initialize args
      @initials = args
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
          @width, @height = @real.getImageData.width, @real.getImageData.height
        elsif @real.is_a? Swt::TextLayout or @real == :shape or @real == :pattern
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
    end

    attr_reader :args, :initials
    attr_accessor :parent

    def move x, y
      @app.cslot.contents -= [self]
      move3 x, y
      self
    end

    def move2 x, y
      move3 x, y
    end

    def move3 x, y
      @left, @top = x, y
    end

    def positioning x, y, max
      if parent.is_a?(Flow) and x + @width <= parent.left + parent.width
        move3 x + parent.margin_left, max.top + parent.margin_top
        max = self if max.height < @height
      else
        move3 parent.left + parent.margin_left, max.top + max.height + parent.margin_top
        max = self
      end
      max
    end
  end

  class Image < Basic; end

  class Pattern < Basic
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

  class ShapeBase < Basic; end
  class Rect < ShapeBase; end
  class Oval < ShapeBase; end
  
  class TextBlock < Basic
    def text
      @args[:markup]
    end
    def text= s
      style markup: s
    end
    def positioning x, y, max
      self.text = @args[:markup]
      super
    end
    def move x, y
      move3 x, y
      self.text = @args[:markup]
      super
    end
    def move2 x, y
      super
      self.text = @args[:markup]
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
    def text
      @real.getText
    end
    def text=(s)
      @real.setText s.to_s
    end
    def move x, y
      @real.setLocation x, y
      super
    end
    def move2 x, y
      @real.setLocation x, y
      super
    end
  end
  class Button < Native; end
  class EditLine < Native; end
  class EditBox < Native; end
  class ListBox < Native; end
end
