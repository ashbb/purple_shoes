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
        elsif @real.is_a? Swt::TextLayout
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
      @real.setLocation(x, y) unless @real.is_a? Swt::Image or @real.is_a? Swt::TextLayout
      move3 x, y
      self
    end

    def move2 x, y
      @real.setLocation(x, y) unless @real.is_a? Swt::Image or @real.is_a? Swt::TextLayout
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
  class Native < Basic; end
  class Button < Native; end

  class TextBlock < Basic
    def text= s
      style markup: s
    end
    def positioning x, y, max
      self.text = @args[:markup]
      super
    end
    def move2 x, y
      self.text = @args[:markup]
      super
    end
  end
  class Banner < TextBlock; end
  class Title < TextBlock; end
  class Subtitle < TextBlock; end
  class Tagline < TextBlock; end
  class Caption < TextBlock; end
  class Para < TextBlock; end
  class Inscription < TextBlock; end
end
