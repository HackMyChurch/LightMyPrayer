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
      movie.each_with_index { |elm, key| 
        puts "##{key}, img lg :#{elm[:image].length}, duration : #{elm[:duration]}"
        uri = URI::Data.new elm[:image]
        image_name = "#{session_id}-"+key.to_s.rjust(4, "0")+".jpg"
        image_file = "#{UPLOAD_PATH}/#{image_name}"
        File.unlink image_file if File.exist? image_file
        # Writing image
        File.open(image_file, 'wb') do |f|
          f.write uri.data 
        end
        }
        keep_last_image_for_moderation image_name, uri
    end

    # cleaning up working directory : deleting images files for a specific sessionId
    # TODO :  keep this independant from OS.
    def cleanup_working_dir(session_id)
      system "rm -f #{UPLOAD_PATH}/#{session_id}-*.jpg"
    end

    # Puts the last image in moderation directory
    def keep_last_image_for_moderation(name, uri)
      File.open("#{MODERATION_PATH}/#{name}", 'wb') do |f|
        f.write uri.data 
      end
    end

  end
end