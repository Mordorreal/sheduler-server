require 'standalone_migrations'
require_relative 'app/manager'

StandaloneMigrations::Tasks.load_tasks

namespace :app do
  task :send_tasks do
    Manager.find_and_send_tasks
  end

end
