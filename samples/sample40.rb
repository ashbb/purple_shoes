# For Christmas
require '../lib/purple_shoes'

Shoes.app width: 330, height: 300 do
  nostroke
  background black
  data, stars = [], []
  5.times{data << [30+rand(10), 20+rand(200), 20+rand(200)]}
  5.times{|j| stars << star(data[j][1], data[j][2], 5, data[j][0], data[j][0]/2.0, fill: gold..white, angle: 45)}
  msg = para fg(strong('Merry Christmas'), white), size: 48
  msg.hide

  a = animate do |i|
    rotate i*5
    stars.each_with_index{|s, j| s.rotate = [i*5, data[j][1], data[j][2]]}
    msg.show if i > 30
    a.stop if i > 50
  end
end
