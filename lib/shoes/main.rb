class Shoes
  $urls = {}
  include Swt
  
  def self.display
    @display
  end
  
  def self.app args={}, &blk
    args[:width] ||= 600
    args[:height] ||= 500
    args[:title] ||= 'purple shoes'
    args[:left] ||= 0
    args[:top] ||= 0

    @display ||= Swt::Display.new
    shell = Swt::Shell.new @display, Swt::SWT::SHELL_TRIM | Swt::SWT::V_SCROLL
    shell.setSize args[:width] + 16, args[:height] + 38
    shell.setText args[:title]
    color = @display.getSystemColor Swt::SWT::COLOR_WHITE
    shell.setBackground color
    icon = Swt::Image.new @display, File.join(DIR, '../static/purple_shoes-icon.png')
    shell.setImage icon
    
    cs = Swt::Composite.new shell, Swt::SWT::TRANSPARENT
    cs.setSize args[:width], args[:height]
    
    args[:shell], args[:cs] = shell, cs
    app = App.new args
    @main_app ||= app
    app.top_slot = Flow.new app.slot_attributes(app: app, left: 0, top: 0)
    
    class << app; self end.class_eval do
      define_method(:width){shell.getSize.x - 16}
      define_method(:height){shell.getSize.y - 38}
    end
    
    app.hided = true
    blk ? app.instance_eval(&blk) : app.instance_eval{$urls[/^#{'/'}$/].call app}
    
    shell.open
    call_back_procs app
    app.aflush

    cl = Swt::ControlListener.new
    class << cl; self end.
    instance_eval do
      define_method(:controlResized){|e| Shoes.call_back_procs app}
      define_method(:controlMoved){|e|}
    end
    shell.addControlListener cl

    vb = shell.getVerticalBar
    vb.setVisible false
    ln = Swt::Listener.new
    class << ln; self end.
    instance_eval do
      define_method :handleEvent do |e|
        location = cs.getLocation
        location.y = -vb.getSelection
        cs.setLocation location
      end
    end
    vb.addListener Swt::SWT::Selection, ln

    mml = Swt::MouseMoveListener.new
    class << mml; self end.
    instance_eval do
      define_method :mouseMove do |e|
        app.mouse_pos = [e.x, e.y]
        Shoes.mouse_motion_control app
        Shoes.mouse_shape_control app
      end
    end
    cs.addMouseMoveListener mml
    
    ml = Swt::MouseListener.new
    class << ml; self end.
    instance_eval do
      define_method(:mouseDown){|e| app.mouse_button = e.button; app.mouse_pos = [e.x, e.y]}
      define_method(:mouseUp){|e| app.mouse_button = 0; app.mouse_pos = [e.x, e.y]}
      define_method(:mouseDoubleClick){|e|}
    end
    cs.addMouseListener ml
  
    if @main_app == app
      while !shell.isDisposed do
        @display.sleep unless @display.readAndDispatch
      end
      @display.dispose
    end
    app
  end
end
