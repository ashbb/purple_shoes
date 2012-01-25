class Shoes
  class Anim
    def initialize n=100, &blk
      @n, @i, @blk = n, 0, blk
    end

    def run
      if continue? 
        @blk[@i = pause? ? @i : @i+1]
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
