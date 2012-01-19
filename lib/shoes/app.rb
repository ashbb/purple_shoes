class Shoes
  class App
    include_swt
    
    def initialize shell
      @shell = shell
    end
    
    def para str
      label = Label.new @shell, SWT::CENTER
      label.setText str
    end
  end
end
