# original code is http://shoes-tutorial-note.heroku.com/html/00409_No.9_Shoes.url.html

require '../lib/purple_shoes'

class PhotoFrame < Shoes
  url '/', :index
  url '/loogink', :loogink
  url '/cy', :cy

  def index
    eval(['loogink', 'cy'][rand 2])
  end

  def loogink
    background tomato
    image File.join(DIR, '../samples/loogink.png'), margin: [70, 10, 0, 0]
    para fg(strong('She is Loogink.'), white),
      '->', margin: 10
    button('Cy', margin: [10, 20, 0, 0]){visit '/cy'}
    p location
  end

  def cy
    background paleturquoise
    image File.join(DIR, '../samples/cy.png'), margin: [70, 10, 0, 0]
    para fg(strong('He is Cy.'), gray), '  ->', margin: 10
    button('loogink', margin: [10, 20, 0, 0]){visit '/loogink'}
    p location
  end
end

Shoes.app width: 210, height: 150, title: 'Photo Frame'
