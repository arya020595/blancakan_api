# frozen_string_literal: true

require 'digest'

module V1
  # Service that provides available options for permissions (e.g., subject_class)
  class PermissionOptionsService
    include Dry::Monads[:result]

    def get_options
      options = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
        {
          subject_class: discover_model_classes.sort
        }
      end

      Success(options)
    end

    private

    def discover_model_classes
      models_path = Rails.root.join('app', 'models')
      return [] unless models_path.exist?

      class_names = []
      Dir.glob(models_path.join('*.rb')).each do |file|
        begin
          basename = File.basename(file, '.rb')
          # exclude ability.rb (authorization definitions)
          next if basename.downcase == 'ability'
          const_name = basename.camelize
          klass = const_name.safe_constantize
          class_names << klass.name if klass
        rescue StandardError
          next
        end
      end

      class_names
    end

    # Cache key that includes a digest of model file mtimes so the cache
    # automatically expires when model files are added/modified/removed.
    def cache_key
      "v1.permission_options_service.options:#{models_digest}"
    end

    def models_digest
      files = Dir.glob(Rails.root.join('app', 'models', '**', '*.rb')).sort
      payload = files.map { |f| "#{f}:#{File.mtime(f).to_i}" }.join('|')
      Digest::SHA1.hexdigest(payload)
    end
  end
end
