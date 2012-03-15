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

  def ask_open_file
    dialog_chooser 'Open File...', Swt::SWT::OPEN
  end
  
  def ask_save_file
    dialog_chooser 'Save File...', Swt::SWT::OPEN
  end
  
  def dialog_chooser title, style
    shell = Swt::Shell.new Shoes.display
    fd = Swt::FileDialog.new shell, style
    fd.setText title
    fd.open
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
