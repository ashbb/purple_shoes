require '../lib/purple_shoes'

Shoes.app title: 'Purple Shoes New Logo Icon!', width: 310, height: 420 do
  stack do
    path = File.join(DIR, '../static/purple_shoes-icon.png')
    image path
    flow do
      image path
      image path
    end
    stack do
      image path
      para ' ' * 20, 'Powered by JRuby and SWT!'
    end
  end
end
