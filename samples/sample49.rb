require '../lib/purple_shoes'

Shoes.app do
  popup = proc{alert 'Testing style method...'}

  s1 = stack width: 0.5, height: 1.0 do
    background cornflowerblue
    @star = star 120, 120, 10, 100, 50
    @star.click &popup
    @msg = para fg('Wait 5 seconds...', yellow), left: 10, top: 450
  end

  s2 = stack width: 0.5, height: 1.0 do
    background coral
    para 'Purple Shoes is one of colorful Shoes. It is written in JRuby with SWT.'
    @para = para 'Testing, ', link('test', &popup), ', test. ',
      strong('Breadsticks. '),
      em('Breadsticks. '),
      code('Breadsticks. '),
      bg(fg(strong(ins('EVEN BETTER.')), white), rgb(255, 0, 192)),
      sub('fine!')
    para 'Yah! Yah! Yah!'
  end

  timer 5 do
    @star.style width: 140, height: 140, left: 90, top: 90, fill: gold..deeppink, outer: 70, inner: 50
    @para.style align: 'center', size: 24, stroke: green
    s1.style width: 0.3
    s2.style width: 0.7
    @msg.text = 'Looks good to me!'
    aflush
  end
end
