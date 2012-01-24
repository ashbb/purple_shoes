require '../lib/purple_shoes'
Shoes.app title: 'Purple Shoes!!', width: 300, height: 300 do
  para "hello world", left: 50, top: 50
  button 'open new window', left: 100, top: 200 do
    Shoes.app{para DIR, left: 50, top: 100}
  end
end
