# Add new method bg and fg to sample17

require 'purple_shoes'

Shoes.app :width => 240, :height => 95 do
  para 'Testing, test, test. ',
    strong('Breadsticks. '),
    em('Breadsticks. '),
    code('Breadsticks. '),
    bg(fg(strong(ins('EVEN BETTER.')), white), rgb(255, 0, 192)),
    sub('fine!')
end
