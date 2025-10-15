# Complete Example: Adding Search to Product Model

This example shows how to add full Elasticsearch search capabilities to a new `Product` model.

## 1. Model Structure

```ruby
# app/models/product.rb
class Product
  include Mongoid::Document
  include Elasticsearch::ProductSearchable  # This is what we'll create

  field :name, type: String
  field :description, type: String
  field :price, type: BigDecimal
  field :category, type: String
  field :brand, type: String
  field :sku, type: String
  field :is_active, type: Boolean, default: true
  field :is_featured, type: Boolean, default: false
  field :stock_count, type: Integer, default: 0
  field :rating, type: Float
  field :tags, type: Array, default: []
  
  # Standard Mongoid timestamps
  field :created_at, type: Time
  field :updated_at, type: Time
end
```

## 2. Elasticsearch Configuration

```ruby
# app/models/concerns/elasticsearch/product_searchable.rb
module Elasticsearch
  module ProductSearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    included do
      # Elasticsearch index configuration
      settings do
        mappings dynamic: false do
          # Text fields for search with keyword subfields for sorting/filtering
          indexes :name, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :description, type: :text, analyzer: 'standard'
          indexes :category, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }
          indexes :brand, type: :text, analyzer: 'standard', fields: {
            keyword: { type: :keyword, ignore_above: 256 }
          }

          # Keyword fields for exact matching and sorting
          indexes :sku, type: :keyword

          # Numeric fields
          indexes :price, type: :scaled_float, scaling_factor: 100
          indexes :stock_count, type: :integer
          indexes :rating, type: :float

          # Boolean fields
          indexes :is_active, type: :boolean
          indexes :is_featured, type: :boolean

          # Array field
          indexes :tags, type: :keyword

          # Date fields
          indexes :created_at, type: :date
          indexes :updated_at, type: :date
        end
      end

      # Define what data gets indexed for Elasticsearch
      def as_indexed_json(_options = {})
        as_json(only: %i[
          name description category brand sku price stock_count rating
          is_active is_featured tags created_at updated_at
        ])
      end
    end

    module ClassMethods
      # Fields that can be searched with text queries
      def elasticsearch_searchable_fields
        %w[name description category brand sku tags]
      end

      # Fields that can be used for sorting
      def elasticsearch_sortable_fields
        %w[
          name category brand price stock_count rating
          is_active is_featured created_at updated_at
          _score _id
        ]
      end

      # Fields that are text fields with keyword subfields for sorting
      def elasticsearch_text_fields_with_keywords
        %w[name category brand]
      end

      # Fields that are boolean type for filtering
      def elasticsearch_boolean_fields
        %w[is_active is_featured]
      end

      # Essential fields that should always be included in Elasticsearch source
      def elasticsearch_essential_fields
        %w[_id name price category is_active is_featured rating]
      end
    end
  end
end
```

## 3. Controller Implementation

```ruby
# app/controllers/api/v1/products_controller.rb
module Api
  module V1
    class ProductsController < ApplicationController
      def index
        result = Product.search_with_filters(search_params)
        
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
                      filter: [:is_active, :is_featured, :category, :brand, :price, :stock_count, :rating, tags: []], 
                      sort: [])
      end
    end
  end
end
```

## 4. Usage Examples

### Basic Search
```ruby
# Search in name, description, category, brand, sku, tags
Product.search_with_filters({ query: "laptop" })
```

### Category Filter
```ruby
Product.search_with_filters({
  query: "gaming",
  filter: { category: "Electronics" }
})
```

### Price Range Filter
```ruby
Product.search_with_filters({
  filter: {
    price: { gte: 100, lte: 500 }  # Between $100-$500
  }
})
```

### Multiple Filters
```ruby
Product.search_with_filters({
  query: "laptop",
  filter: {
    is_active: true,
    is_featured: true,
    category: "Electronics",
    brand: ["Apple", "Dell", "HP"],  # Any of these brands
    price: { gte: 500 },              # $500 or more
    rating: { gte: 4.0 }              # 4 stars or better
  }
})
```

### Sorting Examples
```ruby
# Sort by price (low to high)
Product.search_with_filters({
  query: "laptop",
  sort: "price:asc"
})

# Sort by multiple criteria
Product.search_with_filters({
  query: "laptop",
  sort: ["is_featured:desc", "rating:desc", "price:asc"]
})

# Sort by text field (uses .keyword)
Product.search_with_filters({
  sort: "name:asc"  # Will automatically use name.keyword
})
```

### Pagination
```ruby
Product.search_with_filters({
  query: "laptop",
  page: 3,
  per_page: 12
})
```

## 5. API Endpoint Examples

```bash
# Basic search
GET /api/v1/products?query=laptop

# Category filter
GET /api/v1/products?query=gaming&filter[category]=Electronics

# Price range
GET /api/v1/products?filter[price][gte]=100&filter[price][lte]=500

# Multiple brand filter
GET /api/v1/products?filter[brand][]=Apple&filter[brand][]=Dell

# Boolean filters
GET /api/v1/products?filter[is_active]=true&filter[is_featured]=true

# Sorting
GET /api/v1/products?sort=price:asc
GET /api/v1/products?sort[]=is_featured:desc&sort[]=rating:desc&sort[]=price:asc

# Pagination
GET /api/v1/products?page=2&per_page=20

# Complete example
GET /api/v1/products?query=gaming+laptop&filter[category]=Electronics&filter[is_active]=true&filter[price][gte]=500&sort[]=is_featured:desc&sort[]=rating:desc&page=1&per_page=12
```

## 6. Index Management

```ruby
# Ensure index exists and is populated
Product.elasticsearch_index_manager.ensure_ready

# Get statistics
stats = Product.elasticsearch_index_stats
puts "Total products indexed: #{stats[:count]}"

# Force reindex (useful after schema changes)
Product.reindex_elasticsearch(force: true)
```

## 7. Response Structure

```json
{
  "status": "success",
  "data": [
    {
      "_id": "product_id_123",
      "name": "Gaming Laptop",
      "price": 1299.99,
      "category": "Electronics", 
      "is_active": true,
      "is_featured": true,
      "rating": 4.5
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 48,
    "per_page": 10
  }
}
```

## 8. Common Use Cases

### E-commerce Product Search
```ruby
# Search with filters and sorting commonly used in e-commerce
Product.search_with_filters({
  query: params[:q],                    # User search term
  filter: {
    is_active: true,                    # Only active products
    category: params[:category],        # Category filter
    brand: params[:brands],             # Multi-brand filter
    price: {                            # Price range
      gte: params[:min_price],
      lte: params[:max_price]
    },
    rating: { gte: params[:min_rating] } # Minimum rating
  },
  sort: params[:sort] || "is_featured:desc", # Default to featured first
  page: params[:page] || 1,
  per_page: params[:per_page] || 24
})
```

### Admin Product Management
```ruby
# Admin view with different defaults
Product.search_with_filters({
  query: params[:search],
  filter: {
    is_active: params[:status] == 'active' ? true : nil
  }.compact,
  sort: params[:sort] || "created_at:desc",
  page: params[:page] || 1,
  per_page: params[:per_page] || 50
})
```

This example demonstrates a complete, production-ready implementation that follows all the SOLID principles and best practices established in the system.
