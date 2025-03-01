namespace :elasticsearch do
  desc 'Create indexes and import all models into Elasticsearch'
  task import: :environment do
    models = [User, Role, Permission, Event, Category]

    models.each do |model|
      puts "Creating index for #{model.name}..."
      model.__elasticsearch__.create_index!(force: true)
      puts "Index for #{model.name} created successfully."

      puts "Importing #{model.name}..."
      model.import
      puts "#{model.name} imported successfully."
    end

    puts 'All models imported into Elasticsearch.'
  end
end
