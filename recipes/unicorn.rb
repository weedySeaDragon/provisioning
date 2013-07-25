set_default(:unicorn_user) { app_user }
set_default(:unicorn_pid) { "#{current_path}/tmp/pids/unicorn.pid" }
set_default(:unicorn_config) { "#{shared_path}/config/unicorn.rb" }
set_default(:unicorn_log) { "#{shared_path}/log/unicorn.log" }
set_default(:git_post_receive) { "#{current_path}/.git/hooks/post-receive" }
set_default(:unicorn_workers, 2)

after "provision:install", "unicorn:install"
after "deploy:setup", "unicorn:setup"
after "deploy", "unicorn:add_git_hook"

namespace :unicorn do
  desc "Setup Unicorn initializer and app configuration"
  task :install, roles: :app do
    template "unicorn_init.erb", "/tmp/unicorn_init"
    run "chmod +x /tmp/unicorn_init"
    run "#{sudo} mv /tmp/unicorn_init /etc/init.d/unicorn_#{application}"
    run "#{sudo} update-rc.d -f unicorn_#{application} defaults"
  end

  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "unicorn.rb.erb", unicorn_config
  end

  task :add_git_hook do
    template "post-receive.erb", git_post_receive
    run "chmod a+x #{git_post_receive}"
  end

  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command, roles: :app do
      run "service unicorn_#{application} #{command}"
    end
    after "deploy:#{command}", "unicorn:#{command}"
  end
end
