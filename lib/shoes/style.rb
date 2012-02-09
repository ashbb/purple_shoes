class Shoes
  class Basic
    def style args
      set_args args
      @app.shell.isDisposed ? exit : @app.shell.redraw(@left, @top, @width, @height, false)
    end
    
    def set_args args
      @args.merge!({left: @left, top: @top})
      @args.merge! args
      @args.each{|k, v| instance_variable_set "@#{k}", v}
    end
  end  
  
  class TextBlock
    def style args
      set_args args

      @width = (@left + parent.width <= @app.width) ? parent.width : @app.width - @left
      @width = initials[:width] unless initials[:width].zero?
      @width = 1 unless @width > 0

      if @real
        @real.setWidth @width
        @height = @real.getBounds(0, @markup.length - 1).height
        @app.shell.isDisposed ? exit : @app.shell.redraw(@left, @top, @width, @height, false)
      else
        m = self.class.to_s.downcase[7..-1]
        @app.send m, @markup, @args.merge({width: @width, create_real: true, nocontrol: true})
      end
    end
  end
end
