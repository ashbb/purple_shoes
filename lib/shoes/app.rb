class Shoes
  class App
    include Mod2
    
    def initialize args={}
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end
      App.class_eval do
        attr_accessor *(args.keys - [:width, :height, :title])
      end
      init_app_vars
      @top_slot, @cslot = nil, self
    end
    
    attr_accessor :cslot, :top_slot, :contents, :order
    
    def stack args={}, &blk
      args[:app] = self
      Stack.new slot_attributes(args), &blk
    end
    
    def flow args={}, &blk
      args[:app] = self
      Flow.new slot_attributes(args), &blk
    end
    
    def textblock klass, font_size, *msg
      args = msg.last.class == Hash ? msg.pop : {}
      args = basic_attributes args
      args[:markup] = msg.map(&:to_s).join
      args[:size] ||= font_size
      args[:font] ||= (@font_family or 'sans')
      line_height =  args[:size] * 2

      if args[:create_real]
        tl = Swt::TextLayout.new Shoes.display
        tl.setText args[:markup]
        font = Swt::Font.new Shoes.display, args[:font], args[:size], Swt::SWT::NORMAL
        black = Shoes.display.getSystemColor Swt::SWT::COLOR_BLACK
        style = Swt::TextStyle.new font, black, nil
        tl.setStyle style, 0, args[:markup].length
        pl = Swt::PaintListener.new
        class << pl; self end.
        instance_eval do
          define_method :paintControl do |e|
            tl.setWidth args[:width]
            tl.draw e.gc, args[:left], args[:top]
	    args[:height] = line_height * tl.getLineCount
          end
        end
        @shell.addPaintListener pl
        args[:real] = tl
      else
        args[:real] = false
      end
      args[:app] = self
      klass.new args
    end

    def banner *msg; textblock Banner, 48, *msg; end
    def title *msg; textblock Title, 34, *msg; end
    def subtitle *msg; textblock Subtitle, 26, *msg; end
    def tagline *msg; textblock Tagline, 18, *msg; end
    def caption *msg; textblock Caption, 14, *msg; end
    def para *msg; textblock Para, 12, *msg; end
    def inscription *msg; textblock Para, 10, *msg; end
    
    def image name, args={}
      args = basic_attributes args
      args[:full_width] = args[:full_height] = 0
      img = Swt::Image.new Shoes.display, name
      args[:real], args[:app] = img, self
      
      Image.new(args).tap do |s|
        pl = Swt::PaintListener.new
        class << pl; self end.
        instance_eval do
          define_method :paintControl do |e|
            gc = e.gc
            gc.drawImage img, s.left, s.top
          end
        end
        @shell.addPaintListener pl
        
        if block_given?
          ln = Swt::Listener.new
          class << ln; self end.
          instance_eval do
            define_method :handleEvent do |e|
              yield s if s.left <= e.x and e.x <= s.left + s.width and s.top <= e.y and e.y <= s.top + s.height
            end
          end
          @shell.addListener Swt::SWT::MouseDown, ln
        end
      end
    end

    def button name, args={}
      args = basic_attributes args
      b = Swt::Button.new @shell, Swt::SWT::NULL
      b.setText name
      b.setLocation args[:left], args[:top]
      if args[:width] > 0 and args[:height] > 0
        b.setSize args[:width], args[:height]
      else
        b.pack
      end
      args[:real], args[:text], args[:app] = b, name, self
      Button.new(args).tap do |s|
        b.addSelectionListener do
          yield s
        end if block_given?
      end
    end
    
    def animate n=10, &blk
      n, i = 1000 / n, 0
      Anim.new(@shell, n, &blk).tap do |a|
        Shoes.display.timerExec n, a
      end
    end
  end
end
