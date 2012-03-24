#
# Shoes Clock by Thomas Bell
# posted to the Shoes mailing list on 04 Dec 2007
# Original code for Red Shoes is: https://github.com/shoes/shoes/blob/master/samples/good-clock.rb
# The following is a snippet modified for Purple Shoes, using rotate instead of clear.
#
require 'purple_shoes'

Shoes.app height: 260, width: 250 do
  def draw_background
    background rgb(230, 240, 200)

    fill white
    stroke black
    strokewidth 4
    oval @centerx - 102, @centery - 102, 204, 204

    fill black
    nostroke
    oval @centerx - 5, @centery - 5, 10, 10

    stroke black
    strokewidth 1
    line(@centerx, @centery - 102, @centerx, @centery - 95)
    line(@centerx - 102, @centery, @centerx - 95, @centery)
    line(@centerx + 95, @centery, @centerx + 102, @centery)
    line(@centerx, @centery + 95, @centerx, @centery + 102)
  end
  
  def clock_hand(sw, color=black)
    stroke color
    strokewidth sw
    line @centerx, @centery, @centerx + @radius, @centery
  end
  
  @radius, @centerx, @centery = 90, 126, 140
  draw_background
  stack do
    background black
    @msg = para(fg(' '*3, tr_color("#666")), fg(' '*14, tr_color("#ccc")), 
      strong(fg(' '*5, white)), fg(' '*3, tr_color("#666")), margin: 4, align: 'center')
  end

  ch1 = clock_hand 2, red
  ch2 = clock_hand 5
  ch3 = clock_hand 8

  animate 8 do |i|
    t = Time.new
    h, m, s, u = t.hour, t.min, t.sec, t.usec
    @msg.text = t.strftime("%a") + t.strftime(" %b %d, %Y ") +
      t.strftime("%I:%M") + t.strftime(".%S")
    ch1.rotate = [(t.sec + t.usec * 0.000001) * 6 - 90, @centerx, @centery]
    ch2.rotate = [(t.min + t.sec / 60.0) * 6 - 90, @centerx, @centery]
    ch3.rotate = [(t.hour + t.min / 60.0) * 30 - 90, @centerx, @centery]
  end
end
