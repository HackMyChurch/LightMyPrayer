# coding: utf-8

# Librairies pour l'application
module Helper
  # Module pour la génération de la vidéo
  module Video
    module_function

    def generate_video (session_id)
        begin
          video_file = "#{READY_PATH}/#{session_id}.avi"
          File.unlink video_file if File.exist? video_file

          ffmpeg_cmd = "ffmpeg -f image2 -framerate #{FRAME_RATE} -pattern_type sequence -r #{FRAME_RATE} -i #{UPLOAD_PATH}/#{session_id}-%04d.jpg -s 720x480 #{READY_PATH}/#{session_id}.avi"
          puts "#{ffmpeg_cmd}"
          ret = system ffmpeg_cmd
        rescue 
          puts "Erreur ! La vidéo n'a pas été générée !"
          puts "#{ret}"
        end
    end

  end
end