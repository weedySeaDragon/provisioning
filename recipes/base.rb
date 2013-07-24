def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

namespace :provision do
  desc "Install everything onto the server"
  task :install do
    ssh_options[:keys] = install_user_ssh_key
    set :user, install_user
    apt_update
  end

  task :apt_update do
    run "#{sudo} useradd #{app_user} -s /bin/bash"
    run "#{sudo} mkdir /home/#{app_user}"
    run "#{sudo} mkdir /home/#{app_user}/.ssh"
    upload "#{deploy_key}", "deploy.pub"
    upload "recipes/templates/bashrc", "bashrc"
    upload "recipes/templates/profile", "profile"
    run "#{sudo} mv $HOME/deploy.pub /home/#{app_user}/.ssh/authorized_keys"
    run "#{sudo} mv $HOME/bashrc /home/#{app_user}/.bashrc"
    run "#{sudo} mv $HOME/profile /home/#{app_user}/.profile"
    run "#{sudo} chmod 700 /home/#{app_user}/.ssh"
    run "#{sudo} chmod 400 /home/#{app_user}/.ssh/authorized_keys"
    run "#{sudo} chown #{app_user}:#{app_user} /home/#{app_user} -R"

    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install python-software-properties"
    run "#{sudo} apt-get -y install libxslt-dev libxml2-dev"
    run "#{sudo} apt-get -y install imagemagick"
    run "#{sudo} apt-get -y install fail2ban"
    run "#{sudo} apt-get -y install unattended-upgrades"
  end

end
