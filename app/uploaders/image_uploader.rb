class ImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process convert: 'png'

  version :thumbnail do
    process resize_to_fit: [50, 50]
  end

  def extension_whitelist
    %w[jpg jpeg gif png]
  end
end
