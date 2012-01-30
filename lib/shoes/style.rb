class Shoes
  class TextBlock
    def style args
      args[:markup] ||= @args[:markup]
      args[:size] ||= @args[:size]
      args[:font] ||= @args[:font]
      args[:align] ||= @args[:align]

      (@real.setText '';  @app.shell.isDisposed ? exit : @app.shell.redraw) if @real
      
      @width = (@left + parent.width <= @app.width) ? parent.width : @app.width - @left
      @width = initials[:width] unless initials[:width].zero?
      @height = 20 if @height.zero?
      m = self.class.to_s.downcase[7..-1]
      args = [args[:markup], @args.merge({left: @left, top: @top, width: @width, height: @height, 
        create_real: true, nocontrol: true, size: args[:size], font: args[:font], align: args[:align]})]
      tb = @app.send(m, *args)
      @real, @height = tb.real, tb.height
      @args[:markup], @args[:size], @args[:font], @args[:align] = tb.markup, tb.size, tb.font, tb.align
      @markup, @size, @font, @align = @args[:markup], @args[:size], @args[:font], @args[:align]
    end
  end
end
