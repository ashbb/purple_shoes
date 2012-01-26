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
      Anim.new(n, &blk).tap do |a|
        Shoes.display.timerExec n, a
      end
    end
  end
end
