require '../lib/purple_shoes'

Shoes.app do
  20.times{|i| button("hello%02d" % i){|s| alert s.text}}
end
