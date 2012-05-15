# Original code was written by pjfitzgibbons (Peter Fitzgibbons) in Brown Shoes
# Revised for Purple Shoes by ashbb

require File.join(DIR, '../static/sound_jars/tritonus_share.jar')
require File.join(DIR, '../static/sound_jars/mp3spi1.9.5.jar')
require File.join(DIR, '../static/sound_jars/jl1.0.1.jar')
require File.join(DIR, '../static/sound_jars/jogg-0.0.7.jar')
require File.join(DIR, '../static/sound_jars/jorbis-0.0.15.jar')
require File.join(DIR, '../static/sound_jars/vorbisspi1.0.3.jar')

class Shoes
  class Video
    include_package 'org.eclipse.swt.awt'
    JFile = java.io.File
    import java.io.BufferedInputStream
    import java.io.IOException
    import javax.sound.sampled
    import javax.media
    import javax.media.protocol

    def initialize path, args
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end
      Video.class_eval do
        attr_accessor *args.keys
      end
      
      if path =~ /^(http|https):\/\//
        @save ||= File.basename path
        app.download(path, save: @save){init @save}
      else
        init path
      end
    end

    def init file
      if File.extname(file) == '.mpg'
        cs = Swt::Composite.new @app.cs, Swt::SWT::EMBEDDED
        cs.setSize @width, @height
        cs.setLocation Swt::Point.new(@left, @top)
        locator = MediaLocator.new JFile.new(file).toURL
        source = Manager.createDataSource locator
        player = Manager.createRealizedPlayer source
        frame = SWT_AWT.new_Frame cs
        frame.add player.getControlPanelComponent
        frame.add player.getVisualComponent
        frame.pack
      else
        audio = AudioSystem.getAudioInputStream JFile.new file
        format = audio.getFormat
        af = AudioFormat.new AudioFormat::Encoding::PCM_SIGNED, format.getSampleRate, 16, 
          format.getChannels, format.getChannels * 2, format.getSampleRate, false
        as = AudioSystem.getAudioInputStream af, audio
        @line = AudioSystem.getLine DataLine::Info.new(Clip.java_class, af)
        @line.open as
      end
    end

    def play
      self.time = 0
      start
    end

    def stop
      @line.stop if @line
    end
    alias :pause :stop

    def start
      @line.start if @line
    end
    
    def length
      @line.getMicrosecondLength / 1000 if @line
    end
    
    def time
      @line.getMicrosecondPosition / 1000 if @line
    end
    
    def time=(n)
      @line.setMicrosecondPosition n * 1000 if @line
    end
    
    def position
      time / length.to_f if @line
    end
    
    def position=(f)
      self.time = length * f if @line
    end
    
    def playing?
      @line.isRunning if @line
    end
  end
end

class Shoes
  class App
    def video path, args={}
      args = {left: 0, top: 0, width: 320, height: 240, app: self}.merge args
      Video.new path, args
    end
  end
end
