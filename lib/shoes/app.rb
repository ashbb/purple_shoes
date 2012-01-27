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
      @shell = args[:shell]
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
    
    def para str, args={}
      label = Swt::Label.new @shell, Swt::SWT::LEFT
      label.setText str
      label.setLocation args[:left], args[:top]
      label.pack
    end
    
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
