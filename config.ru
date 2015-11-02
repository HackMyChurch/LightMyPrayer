# -*- encoding: utf-8 -*-

$LOAD_PATH.unshift(File.dirname(__FILE__))
require ::File.expand_path('../app', __FILE__)
require ::File.expand_path('../controller/sinatra_controller', __FILE__)


# map the irectory for moderation purpose
map APP_PATH + "/moderation" do
    run Rack::Directory.new("./content/moderation")
end

# map the irectory for diffusion purpose
map APP_PATH + "/diffusion" do
    run Rack::Directory.new("./content/ready")
end

use Rack::Rewrite do
  # rewrite %r{/.*/(css)/(.*)}, '/$1/$2'
  rewrite %r{/.*/(js)/(.*)}, '/$1/$2'
end   

run SinatraApp
