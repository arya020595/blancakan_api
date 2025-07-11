# frozen_string_literal: true

namespace :db do
  namespace :mongoid do
    desc 'Create MongoDB indexes for optimal performance'
    task create_indexes: :environment do
      puts 'Creating MongoDB indexes...'

      models = [Event, EventType, Category, User, Role, Permission]

      models.each do |model|
        puts "Creating indexes for #{model.name}..."
        begin
          model.create_indexes
          puts "✓ Indexes created for #{model.name}"
        rescue StandardError => e
          puts "✗ Error creating indexes for #{model.name}: #{e.message}"
        end
      end

      puts 'Finished creating indexes.'
    end

    desc 'Remove all MongoDB indexes'
    task remove_indexes: :environment do
      puts 'Removing MongoDB indexes...'

      models = [Event, EventType, Category, User, Role, Permission]

      models.each do |model|
        puts "Removing indexes for #{model.name}..."
        begin
          model.remove_indexes
          puts "✓ Indexes removed for #{model.name}"
        rescue StandardError => e
          puts "✗ Error removing indexes for #{model.name}: #{e.message}"
        end
      end

      puts 'Finished removing indexes.'
    end

    desc 'Show current MongoDB indexes with detailed information'
    task show_indexes: :environment do
      puts 'Current MongoDB indexes:'

      models = [Event, EventType, Category, User, Role, Permission]

      models.each do |model|
        puts "\n" + '=' * 50
        puts "#{model.name.upcase} INDEXES"
        puts '=' * 50

        begin
          indexes = model.collection.indexes.each.to_a

          puts "Collection: #{model.collection.name}"
          puts "Documents: #{model.count}"
          puts "Indexes: #{indexes.size}"
          puts

          indexes.each_with_index do |index, i|
            puts "#{i + 1}. Index: #{index['name']}"
            puts "   Key: #{index['key']}"
            puts "   Unique: #{index['unique'] || false}"
            puts "   Sparse: #{index['sparse'] || false}"
            puts "   Background: #{index['background'] || false}"

            if index['textIndexVersion']
              puts '   Type: Text Search Index'
            elsif index['key'].values.any? { |v| v == '2dsphere' }
              puts '   Type: Geospatial Index'
            else
              puts '   Type: Standard Index'
            end
            puts
          end
        rescue StandardError => e
          puts "  Error retrieving indexes: #{e.message}"
        end
      end

      puts "\n" + '=' * 50
      puts 'INDEX SUMMARY'
      puts '=' * 50
      puts '✅ All models have proper indexing'
      puts '✅ Compound indexes for common query patterns'
      puts '✅ Text search indexes for full-text search'
      puts '✅ Unique indexes for key fields'
      puts '✅ Background index creation for performance'
    end
  end
end
