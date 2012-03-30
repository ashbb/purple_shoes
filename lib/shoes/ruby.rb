class Range 
  def rand 
    conv = (Integer === self.end && Integer === self.begin ? :to_i : :to_f)
    ((Kernel.rand * (self.end - self.begin)) + self.begin).send(conv) 
  end 
end

class Object
  include Types

  def alert msg
    shell = Swt::Shell.new Shoes.display
    mb = Swt::MessageBox.new shell, Swt::SWT::OK | Swt::SWT::ICON_INFORMATION
    mb.setMessage msg.to_s
    mb.open
  end

  def confirm msg
    shell = Swt::Shell.new Shoes.display
    mb = Swt::MessageBox.new shell, Swt::SWT::YES | Swt::SWT::NO | Swt::SWT::ICON_QUESTION
    mb.setMessage msg.to_s
    mb.open == Swt::SWT::YES ? true : false
  end

  def ask_open_file
    dialog_chooser 'Open File...'
  end
  
  def ask_save_file
    dialog_chooser 'Save File...'
  end

  def ask_open_folder
    dialog_chooser 'Open Folder...', :folder
  end

  def ask_save_folder
    dialog_chooser 'Save Folder...', :folder
  end
  
  def dialog_chooser title, folder=false, style=Swt::SWT::OPEN
    shell = Swt::Shell.new Shoes.display
    fd = folder ? Swt::DirectoryDialog.new(shell, style) : Swt::FileDialog.new(shell, style)
    fd.setText title
    fd.open
  end

  def ask_color title = 'Pick a color...'
    shell = Swt::Shell.new Shoes.display
    cd = Swt::ColorDialog.new shell
    cd.setText title
    color = cd.open
    color ? [color.red, color.green, color.blue] : [255, 255, 255]
  end

  def ask msg, args={}
    AskDialog.new(Swt::Shell.new, msg, args).open
  end
end

class Array
  def / len
    a = []
    each_with_index do |x, i|
      a << [] if i % len == 0
      a.last << x
    end
    a
  end

  def dark?
    r, g, b = self
    r + g + b < 0x55 * 3
  end

  def light?
    r, g, b = self
    r + g + b > 0xAA * 3
  end
end

class AskDialog < Swt::Dialog
  def initialize shell, msg, args
    @shell, @msg, @args= shell, msg, args
    super shell
  end

  def open
    display = getParent.getDisplay
    icon = Swt::Image.new display, File.join(DIR, '../static/purple_shoes-icon.png')
    @shell.setImage icon
    @shell.setSize 300, 125
    @shell.setText 'Purple Shoes asks:'
    label = Swt::Label.new @shell, Swt::SWT::NONE
    label.setText @msg
    label.setLocation 10, 10
    label.pack
    text = Swt::Text.new @shell, Swt::SWT::BORDER | Swt::SWT::SINGLE
    text.setLocation 10, 30
    text.setSize 270, 20
    b = Swt::Button.new @shell, Swt::SWT::NULL
    b.setText 'OK'
    b.setLocation 180, 55
    b.pack
    b.addSelectionListener{|e| @ret = text.getText; @shell.close}
    b = Swt::Button.new @shell, Swt::SWT::NULL
    b.setText 'CANCEL'
    b.setLocation 222, 55
    b.pack
    b.addSelectionListener{|e| @ret = nil; @shell.close}
    @shell.open
    while !@shell.isDisposed do
      display.sleep unless display.readAndDispatch
    end
    @ret
  end
end
