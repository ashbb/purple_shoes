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
  end

  class Text
    def initialize m, str, color=nil
      @style, @str, @color = m, str, color
      @to_s = str.map(&:to_s).join
    end
    attr_reader :to_s, :style, :str, :color
  end
end
