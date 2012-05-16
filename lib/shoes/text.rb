class Shoes
  class App
    [:code, :del, :em, :ins, :strong, :sub, :sup].each do |m|
      define_method m do |*str|
        Text.new m, str
      end
    end

    [:bg, :fg].each do |m|
      define_method m do |*str|
        color = str.pop
        Text.new m, str, color
      end
    end

    def link *str, &blk
      Link.new :link, str, &blk
    end

    def font name
      @font_family = name
    end
  end

  class Text
    def initialize m, str, color=nil
      @style, @str, @color = m, str, color
      @to_s = str.map(&:to_s).join
    end
    attr_reader :to_s, :style, :str, :color
    attr_accessor :parent

    def replace *str
      @str = str
      @to_s = str.map(&:to_s).join
      @parent.args[:markup] = @parent.markup = @parent.contents.map(&:to_s).join
      @parent.args[:styles] = @parent.styles = @parent.app.get_styles @parent.contents
      @parent.style markup: @parent.markup
    end
  end

  class Link < Text
    def initialize m, str, color=nil, &blk
      @blk = blk
      super m, str, color
    end
    attr_reader :blk
    attr_accessor :ln, :lh, :sx, :sy, :ex, :ey, :pl, :pt, :pw, :ph, :clickabled, :parent

    def clear
      @parent.app.cs.removeListener Swt::SWT::MouseDown, @ln
      @parent.links.delete self
    end
  end
end
