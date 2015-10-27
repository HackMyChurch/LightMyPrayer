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
          # Writing thumbnail
          File.open("#{UPLOAD_PATH}/#{@sessionId}-#{key}.png", 'wb') do |f|
            f.write uri.data 
          end
        }
        # TODO : Doing a movie with images !
         {'result' => 'Ok'}.to_json
      rescue Exception => e
        puts "#{e.message}"
        e.backtrace[0..10].each { |t| puts "#{t}"}
        {'result' => 'Error', "message" => e.message }.to_json
      end
    end
  end

end
