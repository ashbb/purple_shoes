require '../lib/purple_shoes'

Shoes.app do
  flow width: 0.3 do
    title 'hello ', stroke: green, fill: yellow
  end
  flow width: 0.7 do
    tagline 'hello ' * 30
  end
end
