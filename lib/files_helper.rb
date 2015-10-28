# coding: utf-8

# Librairies pour l'application
module Helper
  # Module pour la génération de la vidéo
  module Files
    module_function

    # Puts uploaded image in working directory
    def write_images(movie, session_id)
        movie.each_with_index { |elm, key| 
          puts "##{key}, img lg :#{elm[:image].length}, duration : #{elm[:duration]}"
          uri = URI::Data.new elm[:image]
          image_file = "#{UPLOAD_PATH}/#{session_id}-"+key.to_s.rjust(4, "0")+".jpg"
          File.unlink image_file if File.exist? image_file
          # Writing image
          File.open(image_file, 'wb') do |f|
            f.write uri.data 
          end
        }
    end

    # cleaning up working directory : deleting images files for a specific sessionId
    def cleanup_working_dir(session_id)
      system "rm -f #{UPLOAD_PATH}/#{session_id}-*.jpg"
    end

  end
end