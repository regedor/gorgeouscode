require "fileutils"

namespace :local_db do
  desc "Backup database and pull from heroku"
  task pull_from_heroku: :environment do
    FileUtils.mkdir_p(File.join("gc_backups", "db")) unless File.exist?(File.join("gc_backups", "db"))
    system "pg_dump gorgeous-code-alpha_development > gc_backups/db/#{Time.current.strftime('%Y%m%d%H%M%S')}_local_db"
    system "dropdb gorgeous-code-alpha_development"
    system "heroku pg:pull DATABASE_URL gorgeous-code-alpha_development --app gorgeouscode-alpha"
  end

  desc "Push local database to heroku"
  task push_to_heroku: :environment do
    system "heroku pg:reset DATABASE_URL --confirm gorgeouscode-alpha"
    system "heroku pg:push gorgeous-code-alpha_development DATABASE_URL --app gorgeouscode-alpha"
  end
end
