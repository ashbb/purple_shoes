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
      Shoes.APPS << self
    end
    
    attr_accessor :cslot, :top_slot, :contents, :mmcs, :mscs, :order, :mouse_pos, :hided
    attr_writer :mouse_button
    attr_reader :location

    def visit url
      if url =~ /^(http|https):\/\//
        require 'rbconfig'
        Thread.new do
          case RbConfig::CONFIG['host_os']
          when /mswin/; system "start #{url}"
          when /linux/; system("/etc/alternatives/x-www-browser #{url} &")
          else
            puts "Sorry, your platform [#{RUBY_PLATFORM}] is not supported..."
          end
        end
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
      aflush
    end

    def click &blk
      if blk
        app = self
        Swt::Listener.new.tap do |ln|
          class << ln; self end.
          instance_eval do
            define_method(:handleEvent){|e| blk[*app.mouse]}
            define_method(:clear){app.cs.removeListener Swt::SWT::MouseDown, ln}
          end
          @cs.addListener Swt::SWT::MouseDown, ln unless @cs.isDisposed
        end
      end
    end
    
    def textblock klass, font_size, *msg
      args = msg.last.class == Hash ? msg.pop : {}
      args = eval("#{klass.to_s[7..-1].upcase}_DEFAULT").merge args
      args = basic_attributes args
      args[:markup] = msg.map(&:to_s).join

      styles = get_styles msg
      args[:styles] = styles unless styles.empty?

      args[:size] ||= font_size
      args[:font] ||= (@font_family or 'sans')
      args[:stroke] ||= black
      args[:rotate] ||= rotate
      
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
              gc = e.gc
              Shoes.dps_reset s.dps, gc
              tl.setText s.markup
              s.app.set_styles s, args
              tl.setWidth s.width if s.width > 0
              unless s.hided
                Shoes.set_rotate gc, *s.rotate do
                  tl.draw gc, s.left, s.top
                end
              end
            end
          end
          @cs.addPaintListener pl unless @cs.isDisposed
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
      args[:rotate] ||= rotate
      img = Swt::Image.new Shoes.display, name
      args[:full_width], args[:full_height] = img.getImageData.width, img.getImageData.height
      args[:real], args[:app] = img, self
      
      Image.new(args).tap do |s|
        pl = Swt::PaintListener.new
        s.pl = pl
        class << pl; self end.
        instance_eval do
          define_method :paintControl do |e|
            gc = e.gc
            Shoes.dps_reset s.dps, gc
            unless s.hided
              Shoes.set_rotate e.gc, *s.rotate do
                if s.initials[:width].zero? and s.initials[:height].zero?
                  gc.drawImage img, s.left, s.top
                else
                  s.width = s.full_width if s.width.zero?
                  s.height = s.full_height if s.height.zero?
                  gc.drawImage img, 0, 0, s.full_width, s.full_height, s.left, s.top, s.width, s.height
                end
              end
            end
          end
        end
        @cs.addPaintListener pl unless @cs.isDisposed
        clickable s, &blk
      end
    end

    def buttonbase klass, name, args, &blk
      args = basic_attributes args
      args[:block] = blk
      opt = if klass == Button then Swt::SWT::NULL
        elsif klass == Radio then Swt::SWT::RADIO
        elsif klass == Check then Swt::SWT::CHECK end
      b = Swt::Button.new @cs, opt
      b.setText name if klass == Button
      b.setLocation args[:left], args[:top]
      if args[:width] > 0 and args[:height] > 0
        b.setSize args[:width], args[:height]
      else
        b.pack
      end
      args[:real], args[:text], args[:app] = b, name, self
      klass.new(args).tap do |s|
        b.addSelectionListener do |e|
          klass == Button ? blk[s] : (blk[s] if b.getSelection)
        end if blk
      end
    end

    def button name, args={}, &blk
      buttonbase Button, name, args, &blk
    end

    def radio args={}, &blk
      buttonbase Radio, nil, args, &blk
    end
    
    def check args={}, &blk
      buttonbase Check, nil, args, &blk
    end

    def edit_text attrs
      klass, w, h, style, blk, attrs = attrs
      args = attrs.last.class == Hash ? attrs.pop : {}
      txt = attrs.first unless attrs.empty?
      args = basic_attributes args
      args[:width] = w if args[:width].zero?
      args[:height] = h if args[:height].zero?
      
      el = Swt::Text.new @cs, Swt::SWT::BORDER | style
      el.setText txt || args[:text].to_s
      el.setSize args[:width], args[:height]
      args[:real], args[:app] = el, self
      klass.new(args).tap do |s|
        el.addModifyListener{|e| blk[s]} if blk
      end      
    end
    
    def edit_line *attrs, &blk
      edit_text [EditLine, 200, 20, Swt::SWT::SINGLE, blk, attrs]
    end
    
    def edit_box *attrs, &blk
      edit_text [EditBox, 200, 100, Swt::SWT::MULTI | Swt::SWT::WRAP, blk, attrs]
    end
    
    def list_box args={}
      args = basic_attributes args
      args[:width] = 200 if args[:width].zero?
      args[:height] = 20 if args[:height].zero?
      args[:items] ||= []
      cb = Swt::Combo.new @cs, Swt::SWT::DROP_DOWN
      cb.setSize args[:width], args[:height]
      cb.setItems args[:items].map(&:to_s)
      cb.setText args[:choose].to_s
      args[:real], args[:app] = cb, self
      ListBox.new(args).tap do |s|
        cb.addSelectionListener do |e|
          yield s
        end if block_given?
      end
    end
    
    def animate n=10, repaint=true, &blk
      n, i = 1000 / n, 0
      Anim.new(@cs, n, repaint, &blk).tap do |a|
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
    
    def keypress &blk
      Swt::KeyListener.new.tap do |kl|
        class << kl; self end.
        instance_eval do
          define_method(:keyPressed){|e| blk[KEY_NAMES[e.keyCode] || e.character.chr]}
          define_method(:keyReleased){|e|}
          define_method(:clear){Shoes.shell.removeKeyListener kl}
        end
        @shell.addKeyListener kl
      end
    end
    
    def mouse
      [@mouse_button, @mouse_pos[0], @mouse_pos[1]]
    end

    def shape args={}, &blk
      args = basic_attributes args
      args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      args[:nocontrol] = args[:noorder] = true
      args[:stroke] ||= stroke
      args[:fill] ||= fill
      args[:rotate] ||= rotate
      args[:real], args[:app], args[:block] = :shape, self, blk
      Shape.new(args).tap do |s|
        pl = Swt::PaintListener.new
        s.pl = pl
        s.real = Swt::Path.new Shoes.display
        class << pl; self end.
        instance_eval do
          define_method :paintControl do |e|
            unless s.hided
              s.real = Swt::Path.new(Shoes.display) if s.real.isDisposed
              gc = e.gc
              Shoes.dps_reset s.dps, gc
              gc.setAntialias Swt::SWT::ON
              sw, pat1, pat2 = s.strokewidth, s.stroke, s.fill
              Shoes.set_rotate gc, *s.rotate do
                if pat2
                  Shoes.set_pattern s, gc, pat2
                  s.instance_eval &s.block
                  gc.fillPath s.real
                end
                if pat1
                  Shoes.set_pattern s, gc, pat1, :Foreground
                  if sw > 0
                    gc.setLineWidth sw
                    s.instance_eval &s.block
                    gc.drawPath s.real
                  end
                end
              end
            end
          end
        end
        @cs.addPaintListener pl unless @cs.isDisposed
      end
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
      if args[:center]
        args[:left] -= args[:width] / 2
        args[:top] -= args[:height] / 2
      end
      args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      args[:nocontrol] = args[:noorder] = true

      args[:stroke] ||= stroke
      args[:fill] ||= fill
      args[:rotate] ||= rotate
      args[:real], args[:app] = :shape, self
      Oval.new(args).tap do |s|
        pl = Swt::PaintListener.new
        s.pl = pl
        class << pl; self end.
        instance_eval do
          define_method :paintControl do |e|
            unless s.hided
              gc = e.gc
              Shoes.dps_reset s.dps, gc
              gc.setAntialias Swt::SWT::ON
              sw, pat1, pat2 = s.strokewidth, s.stroke, s.fill
              Shoes.set_rotate gc, *s.rotate do
                if pat2
                  Shoes.set_pattern s, gc, pat2
                  gc.fillOval s.left+sw, s.top+sw, s.width-sw*2, s.height-sw*2
                end
                if pat1
                  Shoes.set_pattern s, gc, pat1, :Foreground
                  if sw > 0
                    gc.setLineWidth sw
                    gc.drawOval s.left+sw/2, s.top+sw/2, s.width-sw, s.height-sw
                  end
                end
              end
            end
          end
        end
        @cs.addPaintListener pl unless @cs.isDisposed
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
      if args[:center]
        args[:left] -= args[:width] / 2
        args[:top] -= args[:height] / 2
      end
      args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      args[:curve] ||= 0
      args[:nocontrol] = args[:noorder] = true
      args = basic_attributes args

      args[:stroke] ||= stroke
      args[:fill] ||= fill
      args[:rotate] ||= rotate
      args[:real], args[:app] = :shape, self
      Rect.new(args).tap do |s|
        pl = Swt::PaintListener.new
        s.pl = pl
        class << pl; self end.
        instance_eval do
          define_method :paintControl do |e|
            unless s.hided
              gc = e.gc
              Shoes.dps_reset s.dps, gc
              gc.setAntialias Swt::SWT::ON
              sw, pat1, pat2 = s.strokewidth, s.stroke, s.fill
              Shoes.set_rotate gc, *s.rotate do
                if pat2
                  Shoes.set_pattern s, gc, pat2
                  gc.fillRoundRectangle s.left+sw/2, s.top+sw/2, s.width-sw, s.height-sw, s.curve*2, s.curve*2
                end
                if pat1
                  Shoes.set_pattern s, gc, pat1, :Foreground
                  if sw > 0
                    gc.setLineWidth sw
                    gc.drawRoundRectangle s.left+sw/2, s.top+sw/2, s.width-sw, s.height-sw, s.curve*2, s.curve*2
                  end
                end
              end
            end
          end
        end
        @cs.addPaintListener pl unless @cs.isDisposed
        clickable s, &blk
      end
    end

    def line *attrs, &blk
      args = attrs.last.class == Hash ? attrs.pop : {}
      case attrs.length
        when 0, 1, 2
        when 3; args[:sx], args[:sy], args[:ex] = attrs; args[:ey] = args[:ex]
        else args[:sx], args[:sy], args[:ex], args[:ey] = attrs
      end
      sx, sy, ex, ey = args[:sx], args[:sy], args[:ex], args[:ey]
      sw = args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      cw = hsw = sw*0.5
      args[:width], args[:height] = (sx - ex).abs, (sy - ey).abs
      args[:width] += cw
      args[:height] += cw
      args[:nocontrol] = args[:noorder] = true
      args = basic_attributes args
      
      if ((sx - ex) < 0 and (sy - ey) < 0) or ((sx - ex) > 0 and (sy - ey) > 0)
        args[:left] = (sx - ex) < 0 ? sx - hsw : ex - hsw
        args[:top] = (sy - ey) < 0 ? sy - hsw : ey - hsw
      elsif ((sx - ex) < 0 and (sy - ey) > 0) or ((sx - ex) > 0 and (sy - ey) < 0)
        args[:left] = (sx - ex) < 0 ? sx - hsw : ex - hsw
        args[:top] = (sy - ey) < 0 ? sy - hsw : ey - hsw
      elsif !(sx - ex).zero? and (sy - ey).zero?
        args[:left] = (sx - ex) < 0 ? sx : ex
        args[:top] = (sy - ey) < 0 ? sy - hsw : ey - hsw
      elsif (sx - ex).zero? and !(sy - ey).zero?
        args[:left] = (sx - ex) < 0 ? sx - hsw : ex - hsw
        args[:top] = (sy - ey) < 0 ? sy : ey
      else
        args[:left] = sw
        args[:top] = sy
      end

      args[:stroke] ||= stroke
      args[:rotate] ||= rotate
      args[:real], args[:app] = :shape, self
      Line.new(args).tap do |s|
        pl = Swt::PaintListener.new
        s.pl = pl
        class << pl; self end.
        instance_eval do
          define_method :paintControl do |e|
            unless s.hided
              gc = e.gc
              Shoes.dps_reset s.dps, gc
              gc.setAntialias Swt::SWT::ON
              sw, pat = s.strokewidth, s.stroke
              Shoes.set_rotate gc, *s.rotate do
                if pat
                  Shoes.set_pattern s, gc, pat, :Foreground
                  if sw > 0
                    gc.setLineWidth sw
                    gc.drawLine s.sx, s.sy, s.ex, s.ey
                  end
                end
              end
            end
          end
        end
        @cs.addPaintListener pl unless @cs.isDisposed
        clickable s, &blk
      end
    end

    def star *attrs, &blk
      args = attrs.last.class == Hash ? attrs.pop : {}
      case attrs.length
        when 2; args[:left], args[:top] = attrs
        when 5; args[:left], args[:top], args[:points], args[:outer], args[:inner] = attrs
        else
      end
      args[:points] ||= 10; args[:outer] ||= 100.0; args[:inner] ||= 50.0
      args[:width] = args[:height] = args[:outer]*2.0
      args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      args[:nocontrol] = args[:noorder] = true
      args[:stroke] ||= stroke
      args[:fill] ||= fill
      args[:rotate] ||= rotate
      args[:real], args[:app] = :shape, self
      Star.new(args).tap do |s|
        pl = Swt::PaintListener.new
        s.pl = pl
        class << pl; self end.
        instance_eval do
          define_method :paintControl do |e|
            unless s.hided
              gc = e.gc
              Shoes.dps_reset s.dps, gc
              gc.setAntialias Swt::SWT::ON
              sw, pat1, pat2 = s.strokewidth, s.stroke, s.fill
              outer, inner, points, left, top = s.outer, s.inner, s.points, s.left, s.top
              polygon = []
              polygon << left << (top + outer)
              (1..points*2).each do |i|
                angle =  i * Math::PI / points
                r = (i % 2 == 0) ? outer : inner
                polygon << (left + r * Math.sin(angle)) << (top + r * Math.cos(angle))
              end
              Shoes.set_rotate gc, *s.rotate do
                if pat2
                  Shoes.set_pattern s, gc, pat2
                  gc.fillPolygon polygon
                end
                if pat1
                  Shoes.set_pattern s, gc, pat1, :Foreground
                  if sw > 0
                    gc.setLineWidth sw
                    gc.drawPolygon polygon
                  end
                end
              end
            end
          end
        end
        @cs.addPaintListener pl unless @cs.isDisposed
        clickable s, &blk
      end
    end

    def rgb r, g, b, l=1.0
      (r <= 1 and g <= 1 and b <= 1) ? [r*255, g*255, b*255, l] : [r, g, b, l]
    end
  
    %w[fill stroke strokewidth].each do |name|
      eval "def #{name} #{name}=nil; #{name} ? @#{name}=#{name} : @#{name} end"
    end
    
    def rotate angle=nil, left=0, top=0
      angle ? @rotate = [angle, left, top] : @rotate ||= [0, 0, 0]
    end

    def nostroke
      strokewidth 0
    end
    
    def nofill
      @fill = false
    end

    def gradient *attrs
      case attrs.length
        when 1, 2
          pat1, pat2 = attrs
          pat2 = pat1 unless pat2
          return tr_color(pat1)..tr_color(pat2)
        when 5, 6
          pat, l, t, w, h, angle = attrs
          angle = 0 unless angle
        else
        return black..black
      end

      pat = tr_color pat
      color = case pat
        when Range; [tr_color(pat.first), tr_color(pat.last)]
        when Array; [pat, pat]
        when String
          return Swt::Pattern.new(Shoes.display, Swt::Image.new(Shoes.display, pat))
        else
          [black, black]
      end
      Swt::Pattern.new Shoes.display, *pattern_pos(l, t, w, h, -angle), Swt::Color.new(Shoes.display, *color[0][0, 3]), Swt::Color.new(Shoes.display, *color[1][0, 3])
    end

    def tr_color pat
      if pat.is_a?(String) and pat[0] == '#'
        color = pat[1..-1]
        color = color.gsub(/(.)/){$1 + '0'} if color.length == 3
        rgb *color.gsub(/(..)/).map{$1.hex}
      else
        pat
      end
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
              unless s.hided
                gc = e.gc
                Shoes.dps_reset s.dps, gc
                gc.setAntialias Swt::SWT::ON
                Shoes.set_pattern s, gc, pat
                gc.fillRoundRectangle s.left, s.top, s.width, s.height, s.curve*2, s.curve*2
              end
            end
          end
          @cs.addPaintListener pl unless @cs.isDisposed
        end
        oval 0, 0, 0, strokewidth: 0 # A monkey patch for sample 10. I don't know why this line is necessary... xx-P
      end
    end

    def border pat, args={}
      args[:pattern] = pat
      args = basic_attributes args
      args[:curve] ||= 0
      args[:strokewidth] = ( args[:strokewidth] or strokewidth or 1 )
      args[:real] = args[:create_real] ? :pattern : false
      args[:app] = self
      Border.new(args).tap do |s|
        unless s.real
          pat = s.pattern
          sw = s.strokewidth
          pl = Swt::PaintListener.new
          s.pl = pl
          class << pl; self end.
          instance_eval do
            define_method :paintControl do |e|
              unless s.hided
                gc = e.gc
                Shoes.dps_reset s.dps, gc
                gc.setAntialias Swt::SWT::ON
                Shoes.set_pattern s, gc, pat, :Foreground
                if sw > 0
                  gc.setLineWidth sw
                  gc.drawRoundRectangle s.left+sw/2, s.top+sw/2, s.width-sw, s.height-sw, s.curve*2, s.curve*2
                end
              end
            end
          end
          @cs.addPaintListener pl unless @cs.isDisposed
        end
      end
    end

    def progress args={}
      pb = Swt::ProgressBar.new @cs, Swt::SWT::SMOOTH
      if args[:left] or args[:top]
        args[:noorder] = args[:nocontrol] = true
      end
      args[:width] ||= 150
      args[:height] ||= 16
      args = basic_attributes args
      pb.setSize args[:width], args[:height]
      pb.setLocation args[:left], args[:top]
      args[:real], args[:app] = pb, self
      Progress.new args
    end

    def download name, args={}, &blk
      Download.new self, name, args, &blk
    end

    def scroll_top
      cs.getLocation.y
    end
    
    def scroll_top=(n)
      cs.setLocation 0, -n
      shell.getVerticalBar.setSelection n
    end
    
    def scroll_height
      scroll_max + height
    end
    
    def scroll_max
      shell.getVerticalBar.getMaximum - 10
    end

    def clipboard
      Swt::Clipboard.new(Shoes.display).getContents Swt::TextTransfer.getInstance
    end

    def clipboard=(str)
      Swt::Toolkit.getDefaultToolkit.getSystemClipboard.setContents Swt::StringSelection.new(str), Shoes
    end

    def close
      @shell.close
      Shoes.APPS.delete self
    end

    def flush
      unless @cs.isDisposed
        Shoes.call_back_procs self
        @cs.redraw
      end
    end

    def aflush
      @hided = true
      Swt::Display.getDefault.asyncExec do
        Shoes.call_back_procs self
        @hided = false
        @cs.redraw unless @cs.isDisposed
      end
    end

    [:append, :prepend].each do |m|
      define_method m do |*args, &blk|
        top_slot.send m, *args, &blk
      end
    end

    def gray *attrs
      g, a = attrs
      g ? rgb(g*255, g*255, g*255, a) : rgb(128, 128, 128)[0..2]
    end
  end
end
