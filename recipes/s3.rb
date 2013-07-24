set_default(:s3_bucket, "openfoodweb_ec2")
set_default(:s3_access_key_id) { Capistrano::CLI.password_prompt "S3 Access id for bucket: #{s3_bucket}" }
set_default(:s3_secret_access_key) { Capistrano::CLI.password_prompt "S3 Access key for bucket: #{s3_bucket}" }

after "deploy:setup", "s3:setup"
after "deploy:finalize_update", "s3:symlink"

namespace :s3 do
  desc "Generate the s3.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "s3.yml.erb", "#{shared_path}/config/s3.yml"
  end

  desc "Symlink the s3.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/s3.yml #{release_path}/config/s3.yml"
  end
end
