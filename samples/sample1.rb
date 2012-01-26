require '../lib/purple_shoes'

xspeed, yspeed = 10, 6
xdir, ydir = 1, 1

Shoes.app width: 300, height: 300 do
  a = nil
  button('pause'){a.pause}
  button('stop'){a.stop}
  img = image File.join(DIR, '../static/purple_shoes-icon.png')

  x, y = 150, 150
  size = [128, 128]
  pause = 0

  a = animate(24) do |n|
    unless pause == n
      x += xspeed * xdir
      y += yspeed * ydir

      xdir *= -1 if x > 300 - size[0] or x < 0
      ydir *= -1 if y > 300 - size[1] or y < 0

      img.move x.to_i, y.to_i
    end
    pause = n
  end
end
