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
  end

  #
  # Routing
  #

  # Client pour écrire l'intention
  get APP_PATH + '/' do
    erb :ecrire
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
    if params['session'] 
      # begin
      #   uri = URI::Data.new params['thumb']
      #   # Writing thumbnail
      #   File.open("#{APP_ROOT}/public/pictures/#{params['labelthumb']}", 'wb') do |f|
      #     f.write uri.data 
      #   end
      #   # Writing picture
      #   File.open("#{APP_ROOT}/public/pictures/#{params['label']}", 'wb') do |f|
      #     f.write (params['picture'][:tempfile].read)
      #   end
      #   # Updating db.
      #   DB.update_item_image_link @code, params['label']
      #   {'result' => 'Ok'}.to_json
      # rescue Exception => e
      #   puts "#{e.message}"
      #   e.backtrace[0..10].each { |t| puts "#{t}"}
      #   {'result' => 'Error', "message" => e.message }.to_json
      # end
    end
  end

end
