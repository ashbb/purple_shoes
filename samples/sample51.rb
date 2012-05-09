require 'purple_shoes'

Shoes.app width: 200, height: 200 do
  background mintcream
  flow margin: 5 do
    flow height: 190 do
      background File.join(DIR, '../samples/shell.png'), curve: 5
      @line = para strong(' ' * 300), stroke: white
      @line.text = ''
      @line.cursor = -1
    end
  end

  keypress do |k|
    msg = case k
      when "\b"; @line.text[0..-2]
      else
        k.length == 1 ? @line.text + k : nil
    end
    @line.text = msg if msg
    flush
  end
end
