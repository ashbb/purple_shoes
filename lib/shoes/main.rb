class Shoes
  include_swt
  
  def self.app args={}, &blk
    args[:width] ||= 600
    args[:height] ||= 500
    args[:title] ||= 'purple shoes'

    display = Display.new
    shell = Shell.new display
    shell.setSize args[:width], args[:height]
    shell.setText args[:title]
    shell.setLayout RowLayout.new
    icon = Image.new display, File.join(DIR, '../static/purple_shoes-icon.png')
    shell.setImage icon
    
    app = App.new shell
    app.instance_eval &blk
    
    shell.open
  
    while !shell.isDisposed do
      display.sleep unless display.readAndDispatch
    end
    display.dispose
  end
end
