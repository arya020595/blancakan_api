# Elasticsearch Integration Documentation

## Overview

This documentation covers the comprehensive SOLID Elasticsearch implementation for the Rails API. The system provides search, filter, sort, and pagination capabilities with clean architecture and high performance.

## Architecture

### SOLID Principles Implementation

- **Single Responsibility**: Each service has one clear purpose
- **Open/Closed**: Easy to extend with new models without modifying existing code
- **Liskov Substitution**: All searchable models follow the same interface
- **Interface Segregation**: Clean, focused interfaces for each concern
- **Dependency Inversion**: High-level modules don't depend on low-level details

### Core Components

```
app/services/elasticsearch/
├── search_facade.rb           # Main orchestrator (Facade pattern)
├── configuration.rb           # Centralized configuration management
├── query_builder.rb           # Text search query construction
├── filter_builder.rb          # Filter logic construction
├── sort_builder.rb           # Sort logic construction
├── index_manager.rb          # Index lifecycle management
├── elasticsearch_record.rb   # Wrapper for ES results
└── paginated_elasticsearch_results.rb  # Kaminari-compatible pagination

app/models/concerns/elasticsearch/
├── base_searchable.rb        # Shared search functionality
├── event_searchable.rb       # Event-specific configuration
├── user_searchable.rb        # User-specific configuration
└── role_searchable.rb        # Role-specific configuration
```

## 1. What The Code Does

### Configuration System (`configuration.rb`)

The `DEFAULTS` hash provides fallback values for models that don't define their own Elasticsearch configurations:

```ruby
DEFAULTS = {
  sortable_fields: %w[created_at updated_at _score _id],    # Fields that can be sorted
  searchable_fields: %w[],                                  # Fields for text search (empty - models should define)
  text_fields_with_keywords: %w[],                         # Text fields with keyword subfields (empty - models should define)
  boolean_fields: [],                                       # Boolean fields for filtering
  essential_fields: %w[_id],                               # Fields always included in responses
  default_sort: [{ 'created_at' => { 'order' => 'desc' } }] # Default sort order
}.freeze
```

**Field Explanations:**

- **`sortable_fields`**: Common fields that most models can sort by (timestamps, score, ID)
- **`searchable_fields`**: Empty by default - each model should define what fields are searchable
- **`text_fields_with_keywords`**: Empty by default - each model defines text fields that need keyword subfields for sorting
- **`boolean_fields`**: Boolean fields that can be filtered (true/false values)
- **`essential_fields`**: Fields that must always be returned in API responses (acts like a serializer)
- **`default_sort`**: Default sorting when no sort is specified

### SearchFacade (Main Orchestrator)

**Purpose**: Coordinates all search operations using the Facade pattern

**What it does**:
1. Accepts search parameters (query, filters, sort, pagination)
2. Delegates to specialized builders:
   - `QueryBuilder` for text search
   - `FilterBuilder` for filtering logic
   - `SortBuilder` for sorting logic
3. Executes single Elasticsearch query
4. Returns paginated results without database queries

### Specialized Builders

**QueryBuilder**: Handles text search queries
- Builds `multi_match` queries for text search
- Uses model-specific `searchable_fields`
- Supports fuzzy matching

**FilterBuilder**: Handles filtering logic
- Boolean filters (true/false)
- Array filters (inclusion)
- Date range filters
- Keyword exact matches

**SortBuilder**: Handles sorting logic
- Maps sort fields to correct Elasticsearch fields
- Handles text fields with keyword subfields
- Supports multiple sort criteria

### Index Management

**IndexManager**: Manages Elasticsearch index lifecycle
- Creates indices if they don't exist
- Populates indices with data
- Provides index statistics
- Handles reindexing operations

## 2. How to Use It

### Step 1: Make Your Model Searchable

Include the `BaseSearchable` concern in your model:

```ruby
class YourModel
  include Mongoid::Document
  include Elasticsearch::BaseSearchable  # Add this line
end
```

### Step 2: Create Model-Specific Configuration

Create a searchable concern for your model:

```ruby
# app/models/concerns/elasticsearch/your_model_searchable.rb
module Elasticsearch
  module YourModelSearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    included do
      # Define Elasticsearch mappings
      settings do
        mappings dynamic: false do
          indexes :name, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :description, type: :text, analyzer: 'standard'
          indexes :status, type: :keyword
          indexes :is_active, type: :boolean
          indexes :created_at, type: :date
          indexes :updated_at, type: :date
        end
      end

      # Define what gets indexed
      def as_indexed_json(_options = {})
        as_json(only: %i[name description status is_active created_at updated_at])
      end
    end

    module ClassMethods
      # Fields that can be searched with text queries
      def elasticsearch_searchable_fields
        %w[name description]
      end

      # Fields that can be used for sorting
      def elasticsearch_sortable_fields
        %w[name status created_at updated_at _score _id]
      end

      # Text fields with keyword subfields (for sorting)
      def elasticsearch_text_fields_with_keywords
        %w[name status]
      end

      # Boolean fields for filtering
      def elasticsearch_boolean_fields
        %w[is_active]
      end

      # Essential fields always returned (like serializer)
      def elasticsearch_essential_fields
        %w[_id name status]
      end
    end
  end
end
```

### Step 3: Include in Your Model

```ruby
class YourModel
  include Mongoid::Document
  include Elasticsearch::YourModelSearchable  # Add this line
end
```

### Step 4: Use the Search API

#### Basic Search

```ruby
# Simple text search
results = YourModel.search_with_filters({
  query: "search term"
})
```

#### Advanced Search with Filters

```ruby
results = YourModel.search_with_filters({
  query: "search term",
  filter: {
    is_active: true,           # Boolean filter
    status: "published",       # Keyword filter
    category_ids: ["id1", "id2"], # Array inclusion filter
    created_at: {              # Date range filter
      gte: "2024-01-01",
      lte: "2024-12-31"
    }
  }
})
```

#### With Sorting

```ruby
results = YourModel.search_with_filters({
  query: "search term",
  sort: "created_at:desc",     # Single sort
  # OR
  sort: ["name:asc", "created_at:desc"]  # Multiple sorts
})
```

#### With Pagination

```ruby
results = YourModel.search_with_filters({
  query: "search term",
  page: 2,
  per_page: 20
})
```

#### Complete Example

```ruby
results = YourModel.search_with_filters({
  query: "workshop",
  filter: {
    is_active: true,
    status: ["published", "featured"],
    created_at: { gte: "2024-01-01" }
  },
  sort: ["featured:desc", "created_at:desc"],
  page: 1,
  per_page: 10
})

# Access results
results.each do |record|
  puts record.name
  puts record.status
end

# Pagination info
puts "Page: #{results.current_page}"
puts "Total: #{results.total_count}"
puts "Pages: #{results.total_pages}"
```

### Step 5: Index Management

```ruby
# Ensure index exists and is populated
YourModel.elasticsearch_index_manager.ensure_ready

# Get index statistics
stats = YourModel.elasticsearch_index_stats
puts "Documents: #{stats[:count]}"

# Force reindex
YourModel.reindex_elasticsearch(force: true)
```

## API Endpoint Integration

### Controller Example

```ruby
class Api::V1::YourModelsController < ApplicationController
  def index
    result = YourModel.search_with_filters(search_params)
    
    render json: {
      status: 'success',
      data: result,
      meta: {
        current_page: result.current_page,
        total_pages: result.total_pages,
        total_count: result.total_count,
        per_page: result.limit_value
      }
    }
  end

  private

  def search_params
    params.permit(:query, :page, :per_page, :sort, 
                  filter: {}, 
                  sort: [])
  end
end
```

### API Usage Examples

```bash
# Basic search
GET /api/v1/your_models?query=workshop

# With filters
GET /api/v1/your_models?query=workshop&filter[is_active]=true&filter[status]=published

# With sorting
GET /api/v1/your_models?query=workshop&sort=name:asc

# With pagination
GET /api/v1/your_models?query=workshop&page=2&per_page=20

# Combined
GET /api/v1/your_models?query=workshop&filter[is_active]=true&sort=created_at:desc&page=1&per_page=10
```

## Performance Benefits

1. **Single Query**: Only one Elasticsearch query, no database fallbacks
2. **Source Fields**: Only retrieves necessary fields using `essential_fields`
3. **No Database Queries**: Results come directly from Elasticsearch
4. **Efficient Pagination**: Uses Elasticsearch's native pagination

## Configuration Flexibility

The system automatically uses:
- **Model-specific configurations** when available (recommended)
- **Default configurations** as fallback for missing methods

This allows gradual migration and supports models with varying complexity.

## Best Practices

1. **Always define `elasticsearch_searchable_fields`** - don't rely on empty defaults
2. **Keep `essential_fields` minimal** - only include fields needed in API responses  
3. **Use keyword subfields for sorting** text fields
4. **Test index mappings** before production
5. **Monitor index size** and performance
6. **Use appropriate analyzers** for your use case

## Error Handling

The system includes built-in error handling:
- Elasticsearch connectivity issues
- Index creation failures  
- Invalid sort fields
- Query syntax errors

## Extension Points

To add new functionality:
1. Create new builder classes following existing patterns
2. Add configuration methods to model concerns
3. Extend the SearchFacade to use new builders
4. Update Configuration class for new defaults

This architecture makes it easy to add features like:
- Faceted search
- Aggregations
- Auto-complete
- Geographic search
- Custom scoring
