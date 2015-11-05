threads 1,5
workers 4
daemonize
bind 'tcp://0.0.0.0:9292'
environment 'development'
directory '/Users/pgl/developpement/lightmyprayer'
pidfile '/Users/pgl/developpement/lightmyprayer/tmp/puma.pid'
state_path '/Users/pgl/developpement/lightmyprayer/tmp/puma.state'
stdout_redirect '/Users/pgl/developpement/lightmyprayer/tmp/puma.log'
tag 'puma-light-my-prayer'
preload_app!