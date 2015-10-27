# coding: utf-8
require 'sinatra/reloader' if ENV['RACK_ENV'] == 'development'
require 'socket'
require 'data_uri'

# Application Sinatra servant de base
class SinatraApp < Sinatra::Base
  configure do
    set :app_file, __FILE__
    set :port, APP_PORT
    set :root, APP_ROOT
    set :public_folder, proc { File.join(root, 'public') }
    set :inline_templates, true
    set :protection, true
    set :lock, true
    set :bind, '0.0.0.0' # allowing acces to the lan
  end

  configure :development do
    register Sinatra::Reloader
    # also_reload "#{APP_ROOT}/lib/db.rb"
    # dont_reload '/path/to/other/file'
  end

  helpers do
  end

  before do
        @sessionId = params['sessionId'] 
  end

  #
  # Routing
  #

  # Client pour écrire l'intention
  get APP_PATH + '/' do
    redirect APP_PATH + '/ecrire'
  end

  # Client pour écrire l'intention
  get APP_PATH + '/ecrire' do
    erb :ecrire
  end

  # Interface de modération
  get APP_PATH + '/admin' do
    erb :admin
  end

  get APP_PATH + '/diffusion' do
    erb :diffusion 
  end

  #
  # API
  #

  # Posting image in Base64 mode.
  post APP_PATH + '/upload' do  
    if  params['movie'] && @sessionId 
      begin
        movie =  JSON.parse params['movie'], :symbolize_names => true 
        movie.each_with_index { |elm, key| 
          puts "##{key}, img lg :#{elm[:image].length}, duration : #{elm[:duration]}"
          uri = URI::Data.new elm[:image]
          image_file = "#{UPLOAD_PATH}/#{@sessionId}-"+key.to_s.rjust(4, "0")+".jpg"
          File.unlink image_file if File.exist? image_file
          # Writing image
          File.open(image_file, 'wb') do |f|
            f.write uri.data 
          end
        }
        begin
          # Génération de la vidéo
          video_file = "#{READY_PATH}/#{@sessionId}.avi"
          File.unlink video_file if File.exist? video_file

          ffmpeg_cmd = "ffmpeg -f image2 -framerate #{FRAME_RATE} -pattern_type sequence -r #{FRAME_RATE} -i #{UPLOAD_PATH}/#{@sessionId}-%04d.jpg -s 720x480 #{READY_PATH}/#{@sessionId}.avi"
          puts "#{ffmpeg_cmd}"
          ret = system(ffmpeg_cmd)
        rescue
          puts "Erreur ! La vidéo n'a pas été générée !"
          puts "#{ret}"
        end
        # Ici tout va bien !
        {'result' => 'Intention envoyée...'}.to_json
      rescue Exception => e
        puts "#{e.message}"
        e.backtrace[0..10].each { |t| puts "#{t}"}
        {'result' => 'Error', "message" => e.message }.to_json
      end
    end
  end

end
