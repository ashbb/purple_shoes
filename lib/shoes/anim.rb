class Shoes
  class Anim
    def initialize cs, n=100, repaint=true, &blk
      @cs, @n, @repaint, @i, @blk = cs, n, repaint, 0, blk
    end
    
    def run
      if continue? 
        @blk[@i = pause? ? @i : @i+1]
        if @cs.isDisposed
          stop
          return
        elsif @repaint
          @cs.redraw
        end
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
