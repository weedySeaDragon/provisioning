set_default(:postgresql_host, "localhost")
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
set_default(:postgresql_database) { "#{application}_production" }
set_default(:heroku_app) { "buyfood" }

namespace :postgresql do
  desc "Install the latest stable release of PostgreSQL."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} apt-get install language-pack-en-base"
    run "#{sudo} dpkg-reconfigure locales"
    run %Q{#{sudo} update-locale LANG=en_AU.UTF-8 LC_ALL=en_AU.UTF-8}
    # `vagrant reload`
    run "#{sudo} add-apt-repository ppa:pitti/postgresql -y"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install postgresql libpq-dev"
  end
  after "provision:install", "postgresql:install"

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
    run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user} encoding 'UTF8';"}
  end
  after "deploy:setup", "postgresql:create_database"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "postgresql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "postgresql:symlink"

  desc "Download and install backup"
  task :capture_heroku_database do
    # run "heroku pgbackups:capture --app #{heroku_app} --expire"
    # `heroku pgbackups:capture --app #{heroku_app} --expire`
    # backup = Capistrano::CLI.ui.ask "Heroku backup: "
    backup_url = `heroku pgbackups:url --app #{heroku_app}`
    puts "Backup url to download: #{backup_url}"
    run "curl -o latest.dump \"#{backup_url}\""
    run "pg_restore --verbose --clean --no-acl --no-owner -h #{postgresql_host} -U #{postgresql_user}  -d #{postgresql_database} latest.dump"

    puts "TODO: cleanse data, and turn off analytics for non-prod environments"
  end
end
