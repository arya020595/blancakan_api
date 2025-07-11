namespace :elasticsearch do
  # Usage: bundle exec rake elasticsearch:reindex_all
  desc 'Reindex all Elasticsearch models'
  task reindex_all: :environment do
    puts '🔄 Reindexing all Elasticsearch models...'
    puts

    # Get all models that include Elasticsearch
    models = get_elasticsearch_models

    models.each do |model|
      reindex_model(model)
    end

    puts '🎉 All models reindexed successfully!'
  end

  # Usage: bundle exec rake elasticsearch:reindex_model MODEL=Event
  # Usage: bundle exec rake elasticsearch:reindex_model MODEL=Category
  desc 'Reindex specific model (usage: rake elasticsearch:reindex_model MODEL=Event)'
  task reindex_model: :environment do
    model_name = ENV['MODEL']

    if model_name.blank?
      puts '❌ Please specify a model: rake elasticsearch:reindex_model MODEL=Event'
      puts '📋 Available models:'
      get_elasticsearch_models.each do |model|
        puts "   - #{model.name}"
      end
      exit 1
    end

    begin
      model = model_name.constantize
      reindex_model(model)
      puts '🎉 Model reindexed successfully!'
    rescue NameError
      puts "❌ Model '#{model_name}' not found"
      exit 1
    end
  end

  # Usage: bundle exec rake elasticsearch:status
  desc 'Show Elasticsearch indices status'
  task status: :environment do
    puts '📊 Elasticsearch Indices Status:'
    puts

    models = get_elasticsearch_models

    models.each do |model|
      puts "#{model.name}:"
      begin
        if model.__elasticsearch__.index_exists?
          stats = model.__elasticsearch__.client.indices.stats(index: model.index_name)
          total_docs = stats['indices'][model.index_name]['total']['docs']['count']
          puts "  ✅ Index exists: #{model.index_name}"
          puts "  📊 Documents: #{total_docs}"
          puts "  🎯 Expected: #{model.count}"
          puts "  🔄 Status: #{total_docs == model.count ? 'In sync' : 'Out of sync'}"
        else
          puts "  ❌ Index does not exist: #{model.index_name}"
        end
      rescue StandardError => e
        puts "  ⚠️  Error checking index: #{e.message}"
      end
      puts
    end
  end

  private

  def get_elasticsearch_models
    # Get all models that include Elasticsearch::Model
    models = []

    # Scan all models in the app
    Rails.application.eager_load!
    ObjectSpace.each_object(Class).select do |klass|
      next unless klass < ActiveRecord::Base || (defined?(Mongoid::Document) && klass.include?(Mongoid::Document))

      models << klass if klass.respond_to?(:__elasticsearch__)
    end

    models.uniq
  end

  def reindex_model(model)
    puts "🔄 Reindexing #{model.name}..."

    begin
      # Delete existing index if it exists
      if model.__elasticsearch__.index_exists?
        puts "  🗑️  Deleting existing #{model.name} index..."
        model.__elasticsearch__.delete_index!
      end

      # Create new index with current mapping
      puts "  🏗️  Creating new #{model.name} index..."
      model.__elasticsearch__.create_index!

      # Reindex all records
      puts "  📊 Importing #{model.name} records..."
      model.import force: true, refresh: true

      # Verify the index
      count = model.count
      puts "  ✅ Successfully reindexed #{count} #{model.name.downcase} records"
      puts
    rescue StandardError => e
      puts "  ❌ Error reindexing #{model.name}: #{e.message}"
      puts e.backtrace.join("\n")
    end
  end
end
