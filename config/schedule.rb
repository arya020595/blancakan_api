# Dynamically detect Rails environment
rails_env = `cd #{File.expand_path('..', __dir__)} && bin/rails runner "puts Rails.env"`.strip

# Dynamically fetch rbenv paths
rbenv_root = `rbenv root`.strip
rbenv_version = `rbenv version-name`.strip
rbenv_shims = "#{rbenv_root}/shims"

# Set ENV dynamically
env :PATH, "#{rbenv_shims}:#{rbenv_root}/bin:/usr/local/bin:/usr/bin:/bin"
env :RBENV_ROOT, rbenv_root
env :RBENV_VERSION, rbenv_version

# Set log output
set :output, "#{path}/log/cron_log.log"

# Define the cron job with the detected environment
every 1.minute do
  runner 'CarrierWave.clean_cached_files! 1', environment: rails_env
end
