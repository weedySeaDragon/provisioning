after "provision:install", "nodejs:install"

namespace :nodejs do
  desc "Install the latest relase of Node.js"
  task :install, roles: :app do
    run "#{sudo} add-apt-repository ppa:chris-lea/node.js -y"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install nodejs"
  end
end
