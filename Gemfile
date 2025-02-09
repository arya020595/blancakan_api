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

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false
gem 'cancancan', '~> 3.5'
gem 'devise' # Authentication
gem 'devise_token_auth' # Token-based authentication for APIs
gem 'dry-validation'
gem 'mongoid'
gem 'mongoid-locker', '~> 2.1'
gem 'omniauth'
gem 'redis', '~> 5.3'
gem 'rolify', '~> 6.0', '>= 6.0.1'
gem 'sidekiq', '~> 7.3', '>= 7.3.8'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem 'rack-cors'

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
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
