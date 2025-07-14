source 'https://rubygems.org'

ruby '3.3.4'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.5'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'
gem 'jwt', '~> 2.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'aasm', '~> 5.5'
gem 'active_model_serializers', '~> 0.10.2'
gem 'bootsnap', require: false
gem 'cancancan', '~> 3.5'
gem 'carrierwave', '~> 3.1', '>= 3.1.1'
gem 'carrierwave-mongoid', require: 'carrierwave/mongoid'
gem 'cloudinary', '~> 2.2'
gem 'dry-container', '~> 0.11.0'
gem 'dry-monads', '~> 1.7', '>= 1.7.1'
gem 'dry-validation'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'elastic-transport', git: 'git@github.com:elastic/elastic-transport-ruby.git'
gem 'kaminari'
gem 'kaminari-actionview'
gem 'kaminari-mongoid'
gem 'mongoid'
gem 'mongoid-locker', '~> 2.1'
gem 'omniauth'
gem 'redis', '~> 5.3'
gem 'sidekiq', '~> 7.3', '>= 7.3.8'
gem 'whenever', '~> 0.9.4'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem 'rack-cors'
gem 'rswag-api'
gem 'rswag-ui'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'brakeman', '~> 6.1', '>= 6.1.2'
  gem 'byebug', '~> 11.1', '>= 11.1.3'
  gem 'debug', platforms: %i[mri windows]
  gem 'rubocop', '~> 1.71', '>= 1.71.2'

  gem 'database_cleaner-mongoid' # Clean test DB
  gem 'factory_bot_rails' # Test data factory
  gem 'faker' # Generate fake data
  gem 'rspec-rails' # RSpec for testing
  gem 'rswag-specs'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
