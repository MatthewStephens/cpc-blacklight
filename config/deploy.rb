require 'bundler/capistrano'
require 'capistrano_colors'

load 'deploy/assets'

set :application, "imls"
set :repository,  "git@github.com:miller-center/imls.git"
set :branch, fetch(:branch, "master")
set :deploy_to, "/opt/imls"
set :group_writable, false
set :use_sudo, true
set :keep_releases, 3
set :scm, :git
set :user, :imls

default_run_options[:pty]   = true
default_run_options[:shell] = "/bin/bash -l"

ssh_options[:forward_agent] = true

#set :deploy_via, :remote_cache

set :domain, "128.143.8.227"

role :app, domain
role :web, domain
role :db, domain, :primary => true

## deployment tasks
before 'deploy:assets:precompile', 'deploy:symlink_db'
after 'deploy:update', 'deploy:cleanup'

namespace :deploy do
  desc "Symlinks production database.yml"
  task :symlink_db, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end
end

after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
