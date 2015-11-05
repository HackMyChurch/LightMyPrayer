# encoding: utf-8

require_relative '../config/options'

namespace :server do
  desc 'Starts puma server'
  task :start do
    system "puma -C #{APP_ROOT}/config/puma.rb #{APP_ROOT}/config.ru"
  end
  desc 'Stops puma servers'
  task :stop do
    system "pumactl -F #{APP_ROOT}/config/puma.rb stop"
  end
  desc 'Restarts puma servers'
  task :restart do
    system "pumactl -F #{APP_ROOT}/config/puma.rb restart"
  end
end