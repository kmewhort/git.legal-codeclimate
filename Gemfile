source 'https://rubygems.org'

gem 'rails', '4.2.8'

# files
gem 'paperclip'

# Code infrastructure
gem 'virtus'

# database
gem 'sqlite3'

group :development, :test do
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'pg', '~> 0.15' # postgresql database for importing from git.legal core
  gem 'yaml_db'
end

group :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end

