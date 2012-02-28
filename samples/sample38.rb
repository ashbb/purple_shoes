require '../lib/purple_shoes'

Shoes.app width: 250, height: 250 do
  nofill
  r = rect 50, 50, 50, 20, stroke: green
  o = oval 150, 100, 50, 20, stroke: red
  s = star 50, 150, 5, 30, 10, stroke: blue
  
  animate do |i|
    r.rotate = [10*i, 75, 60]
    o.rotate = [10*i, 175, 110]
    s.rotate = [10*i, 50, 150]
  end
end
