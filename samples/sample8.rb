require '../lib/purple_shoes'

Shoes.app do
  10.times do |i|
    button "hello#{i}"
    image File.join(DIR, '../static/purple_shoes-icon.png')
    edit_line
  end
end
