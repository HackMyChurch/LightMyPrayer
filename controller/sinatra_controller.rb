# coding: utf-8
require 'sinatra/reloader' if ENV['RACK_ENV'] == 'development'
require 'socket'
require 'data_uri'

# Application Sinatra servant de base
class SinatraApp < Sinatra::Base
  configure do
    set :app_file, __FILE__
    set :bind, '0.0.0.0' # allowing acces to the lan
    set :inline_templates, true
    set :lock, true
    set :port, APP_PORT
    set :protection, true
    set :public_folder, proc { File.join(root, 'public') }
    set :root, APP_ROOT
    set :server, :puma
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
  get APP_PATH + '/ecrire/?' do
    erb :ecrire
  end

  # Interface de modération
  get APP_PATH + '/admin/?' do
    @moderation_list = Dir.glob("#{MODERATION_PATH}/*.jpg")
    erb :admin
  end

  get APP_PATH + '/diffusion/?' do
    erb :diffusion 
  end

  #
  # API
  #

  # Generate a session id
  get APP_PATH + '/session_id' do
    Helper::Session::generate_session_id
  end

  # Posting image in Base64 mode.
  post APP_PATH + '/upload' do  
    if  params['movie'] && @sessionId 
      begin
        movie = JSON.parse params['movie'], :symbolize_names => true
        Helper::Files::write_images(movie, @sessionId)

        # Génération de la vidéo
        Helper::Video::generate_video @sessionId

        # Ici tout va bien !
        {'result' => 'Intention envoyée...'}.to_json
      rescue Exception => e
        puts "#{e.message}"
        e.backtrace[0..10].each { |t| puts "#{t}"}
        {'result' => 'Error', "message" => e.message }.to_json
      end
    end
  end

  # Posting image in Base64 mode.
  post APP_PATH + '/image/upload' do  
    if  params['image'] # && @sessionId 
      begin
        
        puts "Storing iamge #{params['image'][:filename]}..."
        File.open("#{UPLOAD_PATH}/" + params['image'][:filename], "wb") do |f|
          f.write(params['image'][:tempfile].read)
        end 
        puts "done."

        # Ici tout va bien !
        {'result' => 'Intention envoyée...'}.to_json
      rescue Exception => e
        puts "#{e.message}"
        e.backtrace[0..10].each { |t| puts "#{t}"}
        {'result' => 'Error', "message" => e.message }.to_json
      end
    end
  end

  # List of content to be moderated
  get APP_PATH + '/moderation_list' do  
    Dir["#{MODERATION_PATH}/*.jpg"].to_json
  end

end
