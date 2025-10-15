# MongoDB Search Implementation Documentation

## Overview

This documentation covers the SOLID MongoDB search implementation for models that don't require the complexity of Elasticsearch. This provides search, filter, sort, and pagination capabilities using MongoDB's native features with clean architecture.

## When to Use MongoDB Search vs Elasticsearch

### Use MongoDB Search When:

- Simple text search requirements
- Small to medium dataset size
- Lower complexity needs
- Models with basic search/filter/sort requirements
- Quick implementation needed

### Use Elasticsearch When:

- Complex search requirements (fuzzy matching, advanced relevance)
- Large dataset with high search volume
- Advanced features (facets, aggregations, auto-complete)
- Full-text search across multiple fields with complex scoring

## Architecture

### SOLID Principles Implementation

- **Single Responsibility**: Each service has one clear purpose
- **Open/Closed**: Easy to extend with new models without modifying existing code
- **Liskov Substitution**: All searchable models follow the same interface
- **Interface Segregation**: Clean, focused interfaces for each concern
- **Dependency Inversion**: High-level modules don't depend on low-level details

### Core Components

```
app/services/mongodb_search/
├── search_facade.rb      # Main orchestrator (Facade pattern)
├── configuration.rb      # Centralized configuration management
├── query_builder.rb      # Text search query construction
├── filter_builder.rb     # Filter logic construction
└── sort_builder.rb       # Sort logic construction

app/models/concerns/mongodb_search/
├── base_searchable.rb           # Shared search functionality
├── event_type_searchable.rb     # EventType-specific configuration
└── [other_model_searchable.rb]  # Other model configurations
```

## Configuration System

### Default Configuration (`mongodb_search/configuration.rb`)

```ruby
DEFAULTS = {
  sortable_fields: %w[created_at updated_at _id],        # Universal sort fields
  searchable_fields: %w[],                               # Empty - models must define
  text_fields: %w[],                                     # Fields with text indexes
  boolean_fields: [],                                    # Boolean fields for filtering
  filterable_fields: %w[created_at updated_at],          # Fields that can be filtered
  default_sort: { created_at: -1 }                       # MongoDB sort format
}.freeze
```

**Field Explanations:**

- **`sortable_fields`**: Fields that can be used in sort operations
- **`searchable_fields`**: Fields used for text search (regex or text index)
- **`text_fields`**: Fields with MongoDB text indexes (for `$text` search)
- **`boolean_fields`**: Boolean fields for true/false filtering
- **`filterable_fields`**: Fields that can be filtered with various operators
- **`default_sort`**: Default sort order (MongoDB format: 1=asc, -1=desc)

## Implementation Guide

### Step 1: Create Model-Specific Configuration

```ruby
# app/models/concerns/mongodb_search/your_model_searchable.rb
module MongodbSearch
  module YourModelSearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    module ClassMethods
      # Fields that can be searched with text queries
      def mongodb_searchable_fields
        %w[name description title]
      end

      # Fields that can be used for sorting
      def mongodb_sortable_fields
        %w[name title status created_at updated_at _id]
      end

      # Fields with MongoDB text indexes (for $text search)
      def mongodb_text_fields
        %w[name description]  # Only if you have text indexes on these fields
      end

      # Boolean fields for filtering
      def mongodb_boolean_fields
        %w[is_active is_featured]
      end

      # Fields that can be filtered
      def mongodb_filterable_fields
        %w[name status is_active created_at updated_at]
      end

      # Default sort order
      def mongodb_default_sort
        { created_at: -1 }  # Sort by created_at descending
      end
    end
  end
end
```

### Step 2: Include in Your Model

```ruby
class YourModel
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongodbSearch::YourModelSearchable  # Add this line

  # Your model fields...
end
```

### Step 3: Update Service

```ruby
module V1
  class YourModelService
    include Dry::Monads[:result]

    def index(params = {})
      results = ::YourModel.search_with_filters(params)
      Success(results)
    end
  end
end
```

### Step 4: Update Controller

```ruby
module Api
  module V1
    module Admin
      class YourModelsController < Api::V1::Admin::BaseController
        def index
          result = @your_model_service.index(search_params)
          format_response(result: result, resource: 'your_models', action: :index)
        end

        private

        def search_params
          params.permit(:query, :page, :per_page, :sort,
                        filter: [:field1, :field2, :is_active, :created_at],
                        sort: [])
        end
      end
    end
  end
end
```

## Usage Examples

### Basic Search

```ruby
YourModel.search_with_filters({ query: "search term" })
```

### With Filters

```ruby
YourModel.search_with_filters({
  query: "search term",
  filter: {
    is_active: true,              # Boolean filter
    status: "published",          # Exact match
    category: ["cat1", "cat2"],   # Array inclusion (OR logic)
    created_at: {                 # Date range filter
      gte: "2024-01-01",
      lte: "2024-12-31"
    }
  }
})
```

### With Sorting

```ruby
YourModel.search_with_filters({
  sort: "name:asc",                    # Single sort
  # OR
  sort: ["status:desc", "name:asc"]    # Multiple sorts
})
```

### With Pagination

```ruby
YourModel.search_with_filters({
  query: "search term",
  page: 2,
  per_page: 20
})
```

### Complete Example

```ruby
YourModel.search_with_filters({
  query: "workshop",
  filter: {
    is_active: true,
    status: ["published", "featured"],
    created_at: { gte: "2024-01-01" }
  },
  sort: ["status:desc", "created_at:desc"],
  page: 1,
  per_page: 10
})
```

## EventType Implementation Example

### Model Configuration

```ruby
# app/models/concerns/mongodb_search/event_type_searchable.rb
module MongodbSearch
  module EventTypeSearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    module ClassMethods
      def mongodb_searchable_fields
        %w[name description slug]
      end

      def mongodb_sortable_fields
        %w[name slug sort_order is_active created_at updated_at _id]
      end

      def mongodb_text_fields
        %w[name description]  # EventType has text index on these fields
      end

      def mongodb_boolean_fields
        %w[is_active]
      end

      def mongodb_filterable_fields
        %w[name slug is_active sort_order created_at updated_at]
      end

      def mongodb_default_sort
        { sort_order: 1, name: 1 }  # Sort by sort_order, then name
      end
    end
  end
end
```

### API Usage Examples

```bash
# Basic search
GET /api/v1/admin/event_types?query=workshop

# Filter by active status
GET /api/v1/admin/event_types?filter[is_active]=true

# Sort by name
GET /api/v1/admin/event_types?sort=name:asc

# Sort by multiple criteria
GET /api/v1/admin/event_types?sort[]=sort_order:asc&sort[]=name:asc

# Pagination
GET /api/v1/admin/event_types?page=2&per_page=5

# Combined search, filter, sort, pagination
GET /api/v1/admin/event_types?query=workshop&filter[is_active]=true&sort=name:asc&page=1&per_page=10
```

## MongoDB Features Used

### Text Search

- **Text Index**: Uses MongoDB `$text` search if text indexes are available
- **Regex Fallback**: Falls back to regex search on searchable fields
- **Case Insensitive**: All text searches are case insensitive

### Filtering

- **Exact Match**: String/number exact matching
- **Boolean**: True/false filtering
- **Array Inclusion**: `$in` operator for multiple values
- **Range Queries**: `$gte`, `$gt`, `$lte`, `$lt` for numeric/date ranges
- **Date Parsing**: Automatic date string parsing

### Sorting

- **Multiple Fields**: Support for multiple sort criteria
- **Direction Control**: Ascending (1) and descending (-1) sorting
- **Default Sorting**: Model-specific default sort orders

### Pagination

- **Kaminari Compatible**: Uses same pagination interface as Elasticsearch implementation
- **Page/Per Page**: Standard pagination parameters

## Performance Considerations

### Indexing Recommendations

```ruby
# In your model, add appropriate indexes:
class YourModel
  include Mongoid::Document

  # Text search index
  index({ name: 'text', description: 'text' })

  # Compound indexes for common filter combinations
  index({ is_active: 1, created_at: -1 })
  index({ status: 1, sort_order: 1 })

  # Single field indexes for sorting
  index({ name: 1 })
  index({ created_at: -1 })
end
```

### Best Practices

1. **Add text indexes** for fields you'll search frequently
2. **Create compound indexes** for common filter combinations
3. **Limit searchable fields** to avoid slow regex queries
4. **Use exact matches** when possible instead of text search
5. **Monitor query performance** with MongoDB profiling

## Migration from Old Pattern

### Before (EventType example)

```ruby
# Old pattern
EventType.search(query: "workshop", page: 1, per_page: 10)
```

### After

```ruby
# New pattern - much more flexible
EventType.search_with_filters({
  query: "workshop",
  filter: { is_active: true },
  sort: "name:asc",
  page: 1,
  per_page: 10
})
```

## Comparison with Elasticsearch Implementation

| Feature              | MongoDB Search             | Elasticsearch                   |
| -------------------- | -------------------------- | ------------------------------- |
| **Setup Complexity** | Low                        | High                            |
| **Search Quality**   | Basic text/regex           | Advanced relevance              |
| **Performance**      | Good for small/medium data | Excellent for large data        |
| **Features**         | Basic search/filter/sort   | Advanced (facets, aggregations) |
| **Infrastructure**   | MongoDB only               | Requires Elasticsearch          |
| **Use Case**         | Simple search needs        | Complex search requirements     |

Both implementations follow the same SOLID architecture and API interface, making it easy to switch between them as needs evolve.
