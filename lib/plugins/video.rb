# Original code was written by pjfitzgibbons (Peter Fitzgibbons) in Brown Shoes
# Edited a little bit for Purple Shoes by ashbb

require File.join(DIR, '../static/sound_jars/tritonus_share.jar')
require File.join(DIR, '../static/sound_jars/mp3spi1.9.5.jar')
require File.join(DIR, '../static/sound_jars/jl1.0.1.jar')
require File.join(DIR, '../static/sound_jars/jogg-0.0.7.jar')
require File.join(DIR, '../static/sound_jars/jorbis-0.0.15.jar')
require File.join(DIR, '../static/sound_jars/vorbisspi1.0.3.jar')

class Shoes
  class Video
    JFile = java.io.File
    import java.io.BufferedInputStream
    import javax.sound.sampled
    import java.io.IOException

    BufferSize = 4096

    def initialize args
      @initials = args
      args.each do |k, v|
        instance_variable_set "@#{k}", v
      end
      Video.class_eval do
        attr_accessor *args.keys
      end
    end

    def play
      Thread.new do
        audio_input_stream = AudioSystem.getAudioInputStream JFile.new(@path)
        audio_format = audio_input_stream.getFormat
        rawplay *decode_input_stream(audio_format, audio_input_stream)
        audio_input_stream.close
      end
    end

    def decode_input_stream audio_format, audio_input_stream
      case audio_format.encoding
        when Java::JavazoomSpiVorbisSampledFile::VorbisEncoding, Java::JavazoomSpiMpegSampledFile::MpegEncoding
          decoded_format = AudioFormat.new(AudioFormat::Encoding::PCM_SIGNED, audio_format.getSampleRate(), 16,
            audio_format.getChannels(), audio_format.getChannels() * 2, audio_format.getSampleRate(), false)
          decoded_audio_input_stream = AudioSystem.getAudioInputStream(decoded_format, audio_input_stream)
          return decoded_format, decoded_audio_input_stream
        else
          return audio_format, audio_input_stream
      end
    end

    def rawplay(decoded_audio_format, decoded_audio_input_stream)
      sampled_data = Java::byte[BufferSize].new
      line = getLine(decoded_audio_format)
      if line != nil
        line.start()
        bytes_read = 0, bytes_written = 0
        while bytes_read != -1
          bytes_read = decoded_audio_input_stream.read(sampled_data, 0, sampled_data.length)
          if bytes_read != -1
            bytes_written = line.write(sampled_data, 0, bytes_read)
          end
        end
        line.drain()
        line.stop()
        line.close()
        decoded_audio_input_stream.close()
      end
    end

    def getLine(audioFormat)
      res = nil
      info = DataLine::Info.new(SourceDataLine.java_class, audioFormat)
      res = AudioSystem.getLine(info)
      res.open(audioFormat)
      res
    end
  end
end

class Shoes
  class App
    def video file
      args = {}
      args[:real], args[:app], args[:path] = nil, self, file
      Video.new args
    end
  end
end
