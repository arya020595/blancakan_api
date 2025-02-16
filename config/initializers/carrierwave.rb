CarrierWave.configure do |config|
  config.cache_storage = :file
  config.fog_provider = 'fog/cloudinary'
  config.fog_credentials = {
    provider: 'Cloudinary',
    cloud_name: Rails.application.credentials.dig(:cloudinary, :cloud_name),
    api_key: Rails.application.credentials.dig(:cloudinary, :api_key),
    api_secret: Rails.application.credentials.dig(:cloudinary, :api_secret)
  }
end
