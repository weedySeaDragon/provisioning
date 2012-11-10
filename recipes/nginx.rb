namespace :nginx do
  desc "Install latest stable release of nginx"
  task :install, roles: :web do
    run "#{sudo} add-apt-repository ppa:nginx/stable -y"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install nginx"
  end
  after "provision:install", "nginx:install"

  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    puts "TODO: Support supplied SSL certificate!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    nginx_conf = "/etc/nginx"
    run "#{sudo} openssl req -new -nodes -keyout #{nginx_conf}/server.key -out #{nginx_conf}/server.csr -subj \"/C=AU/ST=Victoria/L=Melbourne/O=#{application}/OU=IT/CN=#{application}\""
    run "#{sudo} openssl x509 -req -days 365 -in #{nginx_conf}/server.csr -signkey #{nginx_conf}/server.key -out #{nginx_conf}/server.crt"

    template "nginx_unicorn.erb", "/tmp/nginx_conf"
    run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{application}"
    run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
    restart
  end
  after "deploy:setup", "nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      run "#{sudo} service nginx #{command}"
    end
  end
end
