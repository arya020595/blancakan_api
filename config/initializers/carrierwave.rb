CarrierWave.configure do |config|
  config.cache_storage = :file

  # Fog configuration disabled - use cloudinary gem directly
  # Uncomment and add fog-aws gem if you need S3/Fog storage
  # config.fog_directory = 'fog/cloudinary'
  # config.fog_credentials = {
  #   provider: 'Cloudinary',
  #   cloud_name: Rails.application.credentials.dig(:cloudinary, :cloud_name),
  #   api_key: Rails.application.credentials.dig(:cloudinary, :api_key),
  #   api_secret: Rails.application.credentials.dig(:cloudinary, :api_secret)
  # }
end

# NOTE: The Cloudinary CarrierWave warning is a known compatibility issue
# between CarrierWave 3.x and Cloudinary 2.x. It's harmless and doesn't
# affect functionality. The warning will be resolved when Cloudinary
# releases an updated version compatible with CarrierWave 3.x.
