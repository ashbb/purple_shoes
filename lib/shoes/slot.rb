class Shoes
  class Slot
    include Mod
    def initialize args={}
      @initials = args
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end
      
      Slot.class_eval do
        attr_accessor *(args.keys - [:app])
      end

      set_margin

      @parent = @app.cslot
      @app.cslot = self
      @contents = []
      (@parent.contents << self) unless @nocontrol

      if block_given?
        yield
        @app.cslot = @parent
      else
        @left = @top = 0
      end
    end

    attr_accessor :contents
    attr_reader :parent, :initials
    attr_writer :app

    def app &blk
      blk ? @app.instance_eval(&blk) : @app
    end

    def move3 x, y
      @left, @top = x, y
    end

    def positioning x, y, max
      w = (parent.width * @initials[:width]).to_i if @initials[:width].is_a? Float
      w = (parent.width + @initials[:width]) if @initials[:width] < 0
      @width = w - (margin_left + margin_right) if w
      if parent.is_a?(Flow) and x + @width <= parent.left + parent.width
        move3 x + parent.margin_left, max.top + parent.margin_top
        @height = Shoes.contents_alignment self
        max = self if max.height < @height
        flag = true
      else
        move3 parent.left + parent.margin_left, max.top + max.height + parent.margin_top
        @height = Shoes.contents_alignment self
        max = self
        flag = false
      end
      case @initials[:height]
      when 0
      when Float
        max.height = @height = (parent.height * @initials[:height]).to_i
      else
        max.height = @height = @initials[:height]
      end
      #contents.each &:fix_size
      return max, flag
    end
  end

  class Stack < Slot; end
  class Flow < Slot; end
end