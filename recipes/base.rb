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
    apt_update
  end

  task :apt_update do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install python-software-properties"
    run "#{sudo} apt-get -y install libxslt-dev libxml2-dev"
  end
end
