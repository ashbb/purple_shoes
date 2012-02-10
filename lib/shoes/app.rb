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
    
    attr_accessor :cslot, :top_slot, :contents, :mmcs, :order, :mouse_pos
    attr_writer :mouse_button
    attr_reader :location

    def visit url
      if url =~ /^(http|https):\/\//
        system "start #{url}"
      else
        $urls.each{|k, v| clear{init_app_vars; @location = url; v.call self, $1} if k =~ url}
      end
    end
    
    def stack args={}, &blk
      args[:app] = self
      Stack.new slot_attributes(args), &blk
    end
    
    def flow args={}, &blk
      args[:app] = self
      Flow.new slot_attributes(args), &blk
    end
    
    def clear &blk
      @top_slot.clear &blk
    end
    
    def textblock klass, font_size, *msg
      args = msg.last.class == Hash ? msg.pop : {}
      args = basic_attributes args
      args[:markup] = msg.map(&:to_s).join

      styles = get_styles msg
      args[:styles] = styles unless styles.empty?

      args[:size] ||= font_size
      args[:font] ||= (@font_family or 'sans')
      args[:stroke] ||= black
      
      unless args[:left].zero? and args[:top].zero?
        args[:nocontrol], args[:width] = true, width
        layout_control = false
      else
        layout_control = true
      end

      args[:real] = (args[:create_real] or !layout_control) ? :textblock : false
      args[:app] = self
      
      klass.new(args).tap do |s|
        unless s.real and layout_control
          tl = Swt::TextLayout.new Shoes.display
          s.real = tl
          pl = Swt::PaintListener.new
          s.pl = pl
          class << pl; self end.
          instance_eval do
            define_method :paintControl do |e|
              tl.setText s.markup
              s.app.set_styles tl, args
              tl.setWidth s.width if s.width > 0
              tl.draw e.gc, s.left, s.top
            end
          end
          @shell.addPaintListener pl
        end
      end
    end

    def banner *msg; textblock Banner, 48, *msg; end
    def title *msg; textblock Title, 34, *msg; end
    def subtitle *msg; textblock Subtitle, 26, *msg; end
    def tagline *msg; textblock Tagline, 18, *msg; end
    def caption *msg; textblock Caption, 14, *msg; end
    def para *msg; textblock Para, 12, *msg; end
    def inscription *msg; textblock Para, 10, *msg; end
    
    def image name, args={}, &blk
      args = basic_attributes args
      args[:full_width] = args[:full_height] = 0
      img = Swt::Image.new Shoes.display, name
      args[:real], args[:app] = img, self
      
      Image.new(args).tap do |s|
        pl = Swt::PaintListener.new
        s.pl = pl
        class << pl; self end.
        instance_eval do
          define_method :paintControl do |e|
            gc = e.gc
            gc.drawImage img, s.left, s.top
          end
        end
        @shell.addPaintListener pl
        clickable s, &blk
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
    
    def edit_text attrs
      klass, w, h, style, blk, attrs = attrs
      args = attrs.last.class == Hash ? attrs.pop : {}
      txt = attrs.first unless attrs.empty?
      args = basic_attributes args
      args[:width] = w if args[:width].zero?
      args[:height] = h if args[:height].zero?
      
      el = Swt::Text.new @shell, Swt::SWT::BORDER | style
      el.setText txt || args[:text].to_s
      el.setSize args[:width], args[:height]
      args[:real], args[:app] = el, self
      klass.new(args).tap do |s|
        el.addModifyListener{blk[s]} if blk
      end      
    end
    
    def edit_line *attrs, &blk
      edit_text [EditLine, 200, 28, Swt::SWT::SINGLE, blk, attrs]
    end
    
    def edit_box *attrs, &blk
      edit_text [EditBox, 200, 108, Swt::SWT::MULTI | Swt::SWT::WRAP, blk, attrs]
    end
    
    def list_box args={}
      args = basic_attributes args
      args[:width] = 200 if args[:width].zero?
      args[:height] = 28 if args[:height].zero?
      args[:items] ||= []
      cb = Swt::Combo.new @shell, Swt::SWT::DROP_DOWN
      cb.setSize args[:width], args[:height]
      cb.setItems args[:items].map(&:to_s)
      cb.setText args[:choose].to_s
      args[:real], args[:app] = cb, self
      ListBox.new(args).tap do |s|
        cb.addSelectionListener do
          yield s
        end if block_given?
      end
    end
    
    def animate n=10, repaint=true, &blk
      n, i = 1000 / n, 0
      Anim.new(@shell, n, repaint, &blk).tap do |a|
        Shoes.display.timerExec n, a
      end
    end

    def every n=1, &blk
      animate 1.0/n, &blk
    end

    def timer n=1, &blk
      n *= 1000
      Timer.new(self, n, &blk).tap{|t| Shoes.display.timerExec n, t}
    end

    def motion &blk
      @mmcs << blk
    end
    
    def mouse
      [@mouse_button, @mouse_pos[0], @mouse_pos[1]]
    end
    
    def oval *attrs, &blk
      args = attrs.last.class == Hash ? attrs.pop : {}
      case attrs.length
        when 0, 1
        when 2; args[:left], args[:top] = attrs
        when 3; args[:left], args[:top], args[:radius] = attrs
        else args[:left], args[:top], args[:width], args[:height] = attrs
      end
      args = basic_attributes args
      args[:width].zero? ? (args[:width] = args[:radius] * 2) : (args[:radius] = args[:width]/2.0)
      args[:height] = args[:width] if args[:height].zero?
      args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      args[:nocontrol] = args[:noorder] = true

      args[:stroke] ||= stroke
      args[:fill] ||= fill
      args[:real], args[:app] = :shape, self
      Oval.new(args).tap do |s|
        pl = Swt::PaintListener.new
        s.pl = pl
        class << pl; self end.
        instance_eval do
          define_method :paintControl do |e|
            gc = e.gc
            gc.setAntialias Swt::SWT::ON
            sw, pat1, pat2 = s.strokewidth, s.stroke, s.fill
            if pat1
              gc.setForeground Swt::Color.new(Shoes.display, *pat1[0,3])
              gc.setAlpha(pat1[3] ? pat1[3]*255 : 255)
              sw.times{|i| gc.drawOval s.left+i, s.top+i, s.width-i*2-1, s.height-i*2-1}
            end
            if pat2
              gc.setBackground Swt::Color.new(Shoes.display, *pat2[0,3])
              gc.setAlpha(pat2[3] ? pat2[3]*255 : 255)
              gc.fillOval s.left+sw, s.top+sw, s.width-sw*2, s.height-sw*2
            end
          end
        end
        @shell.addPaintListener pl
        clickable s, &blk
      end
    end

    def rect *attrs, &blk
      args = attrs.last.class == Hash ? attrs.pop : {}
      case attrs.length
        when 0, 1
        when 2; args[:left], args[:top] = attrs
        when 3; args[:left], args[:top], args[:width] = attrs
        else args[:left], args[:top], args[:width], args[:height] = attrs
      end
      args[:height] = args[:width] unless args[:height]
      args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      args[:curve] ||= 0
      args[:nocontrol] = args[:noorder] = true
      args = basic_attributes args

      args[:stroke] ||= stroke
      args[:fill] ||= fill
      args[:real], args[:app] = :shape, self
      Rect.new(args).tap do |s|
        pl = Swt::PaintListener.new
        s.pl = pl
        class << pl; self end.
        instance_eval do
          define_method :paintControl do |e|
            gc = e.gc
            gc.setAntialias Swt::SWT::ON
            sw, pat1, pat2 = s.strokewidth, s.stroke, s.fill
            if pat1
              gc.setForeground Swt::Color.new(Shoes.display, *pat1[0,3])
              gc.setAlpha(pat1[3] ? pat1[3]*255 : 255)
              sw.times{|i| gc.drawRoundRectangle s.left+i, s.top+i, s.width-i*2-1, s.height-i*2-1, s.curve, s.curve}
            end
            if pat2
              gc.setBackground Swt::Color.new(Shoes.display, *pat2[0,3])
              gc.setAlpha(pat2[3] ? pat2[3]*255 : 255)
              gc.fillRoundRectangle s.left+sw, s.top+sw, s.width-sw*2, s.height-sw*2, s.curve, s.curve
            end
          end
        end
        @shell.addPaintListener pl
        clickable s, &blk
      end
    end

    def rgb r, g, b, l=1.0
      (r <= 1 and g <= 1 and b <= 1) ? [r*255, g*255, b*255, l] : [r, g, b, l]
    end
  
    %w[fill stroke strokewidth].each do |name|
      eval "def #{name} #{name}=nil; #{name} ? @#{name}=#{name} : @#{name} end"
    end

    def nostroke
      strokewidth 0
    end
    
    def nofill
      @fill = false
    end
    
    def background pat, args={}
      args[:pattern] = pat
      args = basic_attributes args
      args[:curve] ||= 0
      args[:real] = args[:create_real] ? :pattern : false
      args[:app] = self
      Background.new(args).tap do |s|
        unless s.real
          pat = s.pattern
          pl = Swt::PaintListener.new
          s.pl = pl
          class << pl; self end.
          instance_eval do
            define_method :paintControl do |e|
              gc = e.gc
              gc.setAntialias Swt::SWT::ON
              gc.setBackground Swt::Color.new(Shoes.display, *pat[0,3])
              gc.setAlpha(pat[3] ? pat[3]*255 : 255)
              gc.fillRoundRectangle s.left, s.top, s.width, s.height, s.curve*2, s.curve*2
            end
          end
          @shell.addPaintListener pl
        end
        oval 0, 0, 0 # A monkey patch for sample 10. I don't know why this line is necessary... xx-P
      end
    end

    def flush
      Shoes.call_back_procs self
      @shell.redraw unless @shell.isDisposed
    end
  end
end
