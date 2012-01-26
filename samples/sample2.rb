require '../lib/purple_shoes'

Shoes.app title: 'Purple Shoes New Logo Icon!', width: 330, height: 420 do
  stack do
    path = File.join(DIR, '../static/purple_shoes-icon.png')
    image path
    flow do
      image path
      image path
    end
    image path
  end
  para 'Powered by JRuby and SWT!', left: 130, top: 350
end
