class Shoes
  class App
    def initialize shell
      @shell = shell
    end
    
    def para str, args={}
      label = Swt::Label.new @shell, Swt::SWT::LEFT
      label.setText str
      label.setLocation args[:left], args[:top]
      label.pack
    end
  end
end
