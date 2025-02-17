# Uploader class for handling image uploads using CarrierWave and Cloudinary.
class ImageUploader < CarrierWave::Uploader::Base
  # Include Cloudinary's CarrierWave integration.
  include Cloudinary::CarrierWave

  # Convert all uploaded images to PNG format.
  process convert: 'png'

  # Create a thumbnail version of the uploaded image.
  version :thumbnail do
    # Resize the thumbnail version to fit within 50x50 pixels.
    process resize_to_fit: [50, 50]
  end

  # Whitelist allowed file extensions for uploads.
  def extension_whitelist
    %w[jpg jpeg gif png]
  end

  # Generate a unique public ID for the uploaded file in Cloudinary.
  # The ID is constructed using the model's class name, the mounted attribute, and the model's ID.
  def public_id
    "blancakan/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
