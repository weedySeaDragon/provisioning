
load "recipes/base"
load "recipes/nginx"
load "recipes/unicorn"
load "recipes/postgresql"
load "recipes/nodejs"
load "recipes/rbenv"
load "recipes/check"

server "192.168.33.10", :web, :app, :db, primary: true

set :user, "vagrant"
set :application, "openfoodweb"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:openfoodweb/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases
