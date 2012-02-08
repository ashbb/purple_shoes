class Shoes
  class Anim
    def initialize shell, n=100, repaint=true, &blk
      @shell, @n, @repaint, @i, @blk = shell, n, repaint, 0, blk
    end
    
    def run
      if continue? 
        @blk[@i = pause? ? @i : @i+1]
        @shell.redraw if !@shell.isDisposed and @repaint
        Shoes.display.timerExec @n, self
      end
    end
    
    def stop
      @stop = true
    end

    def continue?
      !@stop
    end

    def pause
      @pause = !@pause
    end

    def pause?
      @pause
    end
  end
end
