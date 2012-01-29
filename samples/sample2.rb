require '../lib/purple_shoes'

Shoes.app title: 'Purple Shoes New Logo Icon!', width: 350, height: 420 do
  stack do
    path = File.join(DIR, '../static/purple_shoes-icon.png')
    image path
    flow do
      image path
      image path
    end
    flow do
      image path
      para "\n"*5, 'Powered by JRuby and SWT!', width: 200
    end
  end
end
