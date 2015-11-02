# coding: utf-8

# Librairies pour l'application
module Helper
  # Module pour la génération de la vidéo
  module Files
    module_function

    # Puts uploaded image in working directory
    def write_images(movie, session_id)
      image_name = ""
      uri = nil
      image_index = 0;
      frame_duration = 1000/FRAME_RATE
      log = ""
      movie.each { |elm| 
        uri = URI::Data.new elm[:image]
        # Adjust duration
        log = "##{image_index}, img lg :#{elm[:image].length}, duration : #{elm[:duration]} "
        duration = elm[:duration]
        while  duration >= frame_duration
          log += "."
          write_file UPLOAD_PATH, image_index, session_id, uri
          duration -= frame_duration
          image_index = image_index + 1
        end
        puts log
        }
        # keep last image for moderation purpose
        write_file MODERATION_PATH, image_index, session_id, uri
        # Adds 5 seconds of final image.
        (FRAME_RATE * TIME_KEEPING_FINAL_STATE).to_i.times {
          write_file UPLOAD_PATH, image_index, session_id, uri
          image_index = image_index + 1
        }
    end

    # cleaning up working directory : deleting images files for a specific sessionId
    # TODO :  keep this independant from OS.
    def cleanup_working_dir(session_id)
      system "rm -f #{UPLOAD_PATH}/#{session_id}-*.jpg"
    end

    # Writing image file
    def write_file(dir_path, image_index, session_id, uri)
      image_name = "#{session_id}-"+image_index.to_s.rjust(4, "0")+".jpg"
      image_file = File.join(dir_path, image_name)
      File.unlink image_file if File.exist? image_file
      # Writing file
      File.open(image_file, 'wb') do |f|
        f.write uri.data 
      end     
    end
  end
end