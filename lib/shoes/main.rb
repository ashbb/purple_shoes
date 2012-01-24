class Shoes
  include Swt
  
  def self.app args={}, &blk
    args[:width] ||= 600
    args[:height] ||= 500
    args[:title] ||= 'purple shoes'

    @display ||= Swt::Display.new
    shell = Swt::Shell.new @display
    shell.setSize args[:width], args[:height]
    shell.setText args[:title]
    icon = Swt::Image.new @display, File.join(DIR, '../static/purple_shoes-icon.png')
    shell.setImage icon
    color = @display.getSystemColor Swt::SWT::COLOR_WHITE
    shell.setBackground color
    
    app = App.new shell
    @main_app ||= app
    app.instance_eval &blk
    
    shell.open

    cl = Swt::ControlListener.new
    class << cl; self end.
    instance_eval do
      define_method(:controlResized){Shoes.call_back_procs app}
      define_method(:controlMoved){}
    end
    shell.addControlListener cl
  
    if @main_app == app
      while !shell.isDisposed do
        @display.sleep unless @display.readAndDispatch
      end
      @display.dispose
    end
    app
  end
end
