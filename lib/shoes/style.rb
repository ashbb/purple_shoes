class Shoes
  class App
    def style klass, args={}
      if klass.superclass == Shoes::TextBlock or klass == Shoes::Link or klass == Shoes::Button
        eval("#{klass.to_s[7..-1].upcase}_DEFAULT").clear.merge! args
      end
    end
  end

  class Basic
    def style args = nil
      return @args unless args
      set_args args
      @app.cs.redraw @left, @top, @width, @height, false unless @app.cs.isDisposed
    end
    
    def set_args args
      @args.merge!({left: @left, top: @top})
      @args.merge! args
      @args.each{|k, v| instance_variable_set "@#{k}", v}
    end
  end  

  class Star < ShapeBase
    def style args = nil
      return @args unless args
      set_args args
      w, h = @width+@strokewidth+1, @height+@strokewidth+1
      @app.cs.redraw @left-w/2 , @top-h/2, w, h, false unless @app.cs.isDisposed
    end
  end

  class TextBlock
    def style args = nil
      return @args unless args
      set_args args
      return if @app.cs.isDisposed

      @width = (@left + parent.width <= @app.width) ? parent.width : @app.width - @left
      @width = initials[:width] unless initials[:width].zero?
      @width = 1 unless @width > 0

      if @real
        @real.setWidth @width
        @height = @real.getBounds(0, @markup.length - 1).height
        @app.cs.redraw @left, @top, @width, @height, false unless @app.cs.isDisposed
      else
        m = self.class.to_s.downcase[7..-1]
        @app.send m, @markup, @args.merge({width: @width, create_real: true, nocontrol: true})
      end
    end
  end

  class Slot
    def style args = nil
      args ? [:width, :height].each{|s| @initials[s] = args[s] if args[s]} :
        {width: @width, height: @height}
    end
  end
end
