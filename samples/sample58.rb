require 'purple_shoes'

Shoes.app do
  title 'Sample Sounds', align: 'center', margin: 50

  button "Boing WAV (740ms)" do
    video("./sounds/61847__simon-rue__boink-v3.wav").play
  end

  button "Fog Horn AIFF (18.667s)" do
    video("./sounds/145622__andybrannan__train-fog-horn-long-wyomming.aiff").play
  end

  button "Explosion MP3 (4.800s)" do
    video("./sounds/102719__sarge4267__explosion.mp3").play
  end

  button "Shields UP! OGG (2.473s)" do
    video("./sounds/46492__phreaksaccount__shields1.ogg").play
  end
end
