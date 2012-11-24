load 'deploy'
load 'deploy/assets'
Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

require 'bundler/capistrano'

load "recipes/base"
load "recipes/nginx"
load "recipes/unicorn"
load "recipes/postgresql"
load "recipes/nodejs"
load "recipes/rbenv"
load "recipes/s3"
load "recipes/check"

# server "192.168.33.10", :web, :app, :db, primary: true
server "ec2-54-241-104-172.us-west-1.compute.amazonaws.com", :web, :app, :db, primary: true

# set :user, "vagrant"
set :user, "ubuntu"
set :application, "openfoodweb"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:eaterprises/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "buyfood_test_ec2.pem")]
puts ssh_options[:keys]

after "deploy", "deploy:cleanup" # keep only the last 5 releases
