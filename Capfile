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
#load "recipes/s3"
load "recipes/check"

server "192.168.33.10", :web, :app, :db, primary: true
# server "ec2-54-241-104-172.us-west-1.compute.amazonaws.com", :web, :app, :db, primary: true

set :install_user, "vagrant"
set :app_user, "openfoodweb1"
set :user, app_user
set :application, "openfoodweb"
#set :s3_bucket, "ofn_staging_1"
set :deploy_to, "/home/#{app_user}/apps/#{application}"
set :deploy_key, "staging-deploy.pub"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:eaterprises/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :install_user_ssh_key, [File.join(ENV["HOME"], ".ssh", "vagrant")]
set :deploy_user_ssh_key, [File.join(ENV["HOME"], ".ssh", "staging-deploy")]
ssh_options[:keys] = deploy_user_ssh_key

after "deploy", "deploy:cleanup" # keep only the last 5 releases
