require '../lib/purple_shoes'

Shoes.app width: 330, height: 70 do
  5.times do |i|
    i+=1
    button("sample#{i}"){load File.join(DIR, "../samples/sample#{i}.rb")}
  end
end
