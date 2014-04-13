set_default(:postgresql_host, "localhost")
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
set_default(:postgresql_database) { "#{application}_production" }
# set_default(:heroku_app) { "buyfood" }

after "provision:install", "postgresql:install"
after "postgresql:install","postgresql:create_database"
after "postgresql:create_database","postgresql:backup"
after "deploy:setup"     , "postgresql:setup"
after "deploy:finalize_update", "postgresql:symlink"

namespace :postgresql do
  desc "Install the latest stable release of PostgreSQL."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} apt-get -y install language-pack-en-base"
    run %Q{#{sudo} update-locale LANG=en_AU.UTF-8 LC_ALL=en_AU.UTF-8 LC_CTYPE=en_AU.UTF-8}
    run "#{sudo} dpkg-reconfigure locales"

    # `vagrant reload`
    run "#{sudo} add-apt-repository ppa:pitti/postgresql -y"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install postgresql libpq-dev"
  end

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
    run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user} encoding 'UTF8' LC_CTYPE 'en_AU.UTF-8' LC_COLLATE 'en_AU.UTF-8' TEMPLATE template0;" }
  end

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
    run "echo 'localhost:*:#{postgresql_database}:#{postgresql_user}:#{postgresql_password}' > ~/.pgpass"
    run "chmod 0600 ~/.pgpass"
  end

  desc "Setup automatic backup."
  task :backup, roles: :app do
    template "crontab.erb", "crontab"
    run "#{sudo} crontab -u #{app_user} crontab"
    run 'rm crontab'
  end

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

end
