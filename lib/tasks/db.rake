namespace :db do
  desc "Run db migrations for all databases matching the environment"
  task migrate_all: :environment do
    Rails.configuration.database_configuration.keys.each do |db_name|
      next unless db_name.starts_with? "#{Rails.env}_"
      ActiveRecord::Base.establish_connection db_name.to_sym
      ActiveRecord::Migrator.migrate('db/migrate')
    end
  end
end
