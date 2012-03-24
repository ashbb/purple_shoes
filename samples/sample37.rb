require 'purple_shoes'

Shoes.app width: 330, height: 300 do
  nofill
  rect 100, 20, 130, 251, stroke: red, fill: yellow
  18.times do |i|
    rotate 10*i, 165, 145
    rect 100, 20, 130, 251
  end
end
