class Shoes
  class Anim
    def initialize shell, n=100, &blk
      @shell, @n, @i, @blk = shell, n, 0, blk
    end
    
    def run
      if continue? 
        @blk[@i = pause? ? @i : @i+1]
        @shell.redraw
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
