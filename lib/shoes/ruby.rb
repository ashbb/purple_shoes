class Object
  include Types

  def alert msg
    shell = Swt::Shell.new Shoes.display
    mb = Swt::MessageBox.new shell, Swt::SWT::OK | Swt::SWT::ICON_INFORMATION
    mb.setMessage msg
    mb.open
  end
end
