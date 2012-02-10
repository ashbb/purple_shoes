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

  class Timer
    def initialize app, n=1000, &blk
      @app, @n, @blk = app, n, blk
    end

    def run
      @blk.call
      @app.flush
    end
  end
end
