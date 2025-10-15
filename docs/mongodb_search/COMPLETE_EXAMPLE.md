# Complete Example: Adding MongoDB Search to Product Model

This example shows how to add full MongoDB search capabilities to a new `Product` model using the SOLID MongoDB search implementation.

## 1. Model Structure

```ruby
# app/models/product.rb
class Product
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongodbSearch::ProductSearchable  # This is what we'll create

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

  # Associations
  belongs_to :category_obj, class_name: 'Category', optional: true
  has_many :reviews

  # MongoDB indexes for performance optimization
  index({ name: 1 }, { background: true })
  index({ sku: 1 }, { unique: true, sparse: true, background: true })
  index({ category: 1, is_active: 1 }, { background: true })
  index({ price: 1 }, { background: true })
  index({ rating: -1 }, { background: true })
  index({ is_active: 1, is_featured: 1, created_at: -1 }, { background: true })

  # Text search index for name, description, brand, and tags
  index({
    name: 'text',
    description: 'text',
    brand: 'text',
    tags: 'text'
  }, {
    background: true,
    weights: {
      name: 10,        # Name is most important
      brand: 5,        # Brand is second
      tags: 3,         # Tags are third
      description: 1   # Description is least weighted
    }
  })

  # Validations
  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_count, numericality: { greater_than_or_equal_to: 0 }
  validates :rating, numericality: { in: 0..5 }, allow_nil: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :featured, -> { where(is_featured: true) }
  scope :in_stock, -> { where(:stock_count.gt => 0) }
  scope :by_category, ->(category) { where(category: category) }
end
```

## 2. MongoDB Search Configuration

```ruby
# app/models/concerns/mongodb_search/product_searchable.rb
module MongodbSearch
  module ProductSearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    module ClassMethods
      # Fields that can be searched with text queries
      def mongodb_searchable_fields
        %w[name description brand tags sku category]
      end

      # Fields that can be used for sorting
      def mongodb_sortable_fields
        %w[
          name brand category price stock_count rating
          is_active is_featured created_at updated_at _id
        ]
      end

      # Fields with MongoDB text indexes (for $text search)
      def mongodb_text_fields
        %w[name description brand tags]
      end

      # Fields that are boolean type for filtering
      def mongodb_boolean_fields
        %w[is_active is_featured]
      end

      # Fields that can be filtered
      def mongodb_filterable_fields
        %w[
          name brand category sku price stock_count rating
          is_active is_featured tags created_at updated_at
        ]
      end

      # Default sort order
      def mongodb_default_sort
        { is_featured: -1, rating: -1, created_at: -1 }  # Featured first, then by rating, then newest
      end
    end
  end
end
```

## 3. Service Implementation

```ruby
# app/services/v1/product_service.rb
module V1
  class ProductService
    include Dry::Monads[:result]

    def index(params = {})
      products = ::Product.search_with_filters(params)
      Success(products)
    end

    def show(product)
      return Failure(nil) unless product

      Success(product)
    end

    def create(params)
      form = ::V1::Product::ProductForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      product = ::Product.new(form.attributes)
      if product.save
        Success(product)
      else
        Failure(product.errors.full_messages)
      end
    end

    def update(product, params)
      form = ::V1::Product::ProductForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if product.update(form.attributes)
        Success(product)
      else
        Failure(product.errors.full_messages)
      end
    end

    def destroy(product)
      return Failure(nil) unless product

      if product.destroy
        Success(product)
      else
        Failure(product.errors.full_messages)
      end
    end
  end
end
```

## 4. Controller Implementation

```ruby
# app/controllers/api/v1/products_controller.rb
module Api
  module V1
    class ProductsController < ApplicationController
      def index
        result = @product_service.index(search_params)
        format_response(result: result, resource: 'products', action: :index)
      end

      def show
        result = @product_service.show(@product)
        format_response(result: result, resource: 'products', action: :show)
      end

      def create
        result = @product_service.create(product_params)
        format_response(result: result, resource: 'products', action: :create)
      end

      def update
        result = @product_service.update(@product, product_params)
        format_response(result: result, resource: 'products', action: :update)
      end

      def destroy
        result = @product_service.destroy(@product)
        format_response(result: result, resource: 'products', action: :destroy)
      end

      private

      def search_params
        params.permit(:query, :page, :per_page, :sort,
                      filter: [:name, :brand, :category, :sku, :price, :stock_count, :rating,
                               :is_active, :is_featured, :created_at, :updated_at, tags: []],
                      sort: [])
      end

      def product_params
        params.require(:product).permit(:name, :description, :price, :category, :brand,
                                        :sku, :is_active, :is_featured, :stock_count,
                                        :rating, tags: [])
      end

      def set_product
        @product = Product.find(params[:id])
      end
    end
  end
end
```

## 5. Usage Examples

### Basic Search

```ruby
# Search using MongoDB text index (if available) or regex fallback
Product.search_with_filters({ query: "gaming laptop" })
```

### Category Filter

```ruby
Product.search_with_filters({
  query: "laptop",
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
  query: "gaming",
  filter: {
    is_active: true,
    is_featured: true,
    category: "Electronics",
    brand: ["Apple", "Dell", "HP"],  # Any of these brands (array inclusion)
    price: { gte: 500 },              # $500 or more
    rating: { gte: 4.0 },             # 4 stars or better
    stock_count: { gt: 0 }            # In stock
  }
})
```

### Tag Filtering

```ruby
Product.search_with_filters({
  filter: {
    tags: ["gaming", "portable"]  # Products with gaming OR portable tags
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

# Sort by name (alphabetical)
Product.search_with_filters({
  sort: "name:asc"
})

# Default sort (featured first, then rating, then newest)
Product.search_with_filters({
  query: "laptop"
  # Uses: { is_featured: -1, rating: -1, created_at: -1 }
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

### Date Range Filtering

```ruby
Product.search_with_filters({
  filter: {
    created_at: {
      gte: "2024-01-01",
      lte: "2024-12-31"
    }
  }
})
```

## 6. API Endpoint Examples

```bash
# Basic search
GET /api/v1/products?query=gaming+laptop

# Category filter
GET /api/v1/products?query=laptop&filter[category]=Electronics

# Price range
GET /api/v1/products?filter[price][gte]=100&filter[price][lte]=500

# Multiple brand filter (array)
GET /api/v1/products?filter[brand][]=Apple&filter[brand][]=Dell&filter[brand][]=HP

# Boolean filters
GET /api/v1/products?filter[is_active]=true&filter[is_featured]=true

# Stock filter
GET /api/v1/products?filter[stock_count][gt]=0

# Rating filter
GET /api/v1/products?filter[rating][gte]=4.0

# Tag filters
GET /api/v1/products?filter[tags][]=gaming&filter[tags][]=portable

# Sorting
GET /api/v1/products?sort=price:asc
GET /api/v1/products?sort[]=is_featured:desc&sort[]=rating:desc&sort[]=price:asc

# Pagination
GET /api/v1/products?page=2&per_page=20

# Date range
GET /api/v1/products?filter[created_at][gte]=2024-01-01&filter[created_at][lte]=2024-12-31

# Complete example
GET /api/v1/products?query=gaming+laptop&filter[category]=Electronics&filter[is_active]=true&filter[price][gte]=500&filter[rating][gte]=4.0&sort[]=is_featured:desc&sort[]=rating:desc&page=1&per_page=12
```

## 7. Response Structure

```json
{
  "status": "success",
  "message": null,
  "data": [
    {
      "id": "product_id_123",
      "name": "Gaming Laptop Pro",
      "description": "High-performance gaming laptop with RTX graphics",
      "price": 1299.99,
      "category": "Electronics",
      "brand": "TechBrand",
      "sku": "TLB-GAMING-001",
      "is_active": true,
      "is_featured": true,
      "stock_count": 15,
      "rating": 4.7,
      "tags": ["gaming", "laptop", "high-performance"],
      "created_at": "2024-01-15T10:30:00.000Z",
      "updated_at": "2024-02-01T15:45:00.000Z"
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
# Typical e-commerce search with all features
Product.search_with_filters({
  query: params[:q],                    # User search term
  filter: {
    is_active: true,                    # Only active products
    category: params[:category],        # Category filter
    brand: params[:brands]&.split(','), # Multi-brand filter
    price: {                            # Price range
      gte: params[:min_price]&.to_f,
      lte: params[:max_price]&.to_f
    }.compact,
    rating: { gte: params[:min_rating]&.to_f }.compact, # Minimum rating
    stock_count: { gt: 0 },             # In stock only
    tags: params[:tags]&.split(',')     # Tag filters
  }.compact,
  sort: params[:sort] || ["is_featured:desc", "rating:desc"], # Default sort
  page: params[:page] || 1,
  per_page: params[:per_page] || 24
})
```

### Admin Product Management

```ruby
# Admin view with different defaults and more filters
Product.search_with_filters({
  query: params[:search],
  filter: {
    is_active: params[:status] == 'active' ? true :
               params[:status] == 'inactive' ? false : nil,
    category: params[:category],
    brand: params[:brand],
    stock_count: params[:stock_status] == 'in_stock' ? { gt: 0 } :
                 params[:stock_status] == 'out_of_stock' ? { lte: 0 } : nil
  }.compact,
  sort: params[:sort] || "created_at:desc",
  page: params[:page] || 1,
  per_page: params[:per_page] || 50
})
```

### Featured Products Widget

```ruby
# Homepage featured products
Product.search_with_filters({
  filter: {
    is_active: true,
    is_featured: true,
    stock_count: { gt: 0 }
  },
  sort: "rating:desc",
  per_page: 8
})
```

### Category Page

```ruby
# Products for a specific category
Product.search_with_filters({
  filter: {
    is_active: true,
    category: "Electronics",
    stock_count: { gt: 0 }
  },
  sort: ["is_featured:desc", "rating:desc", "created_at:desc"],
  page: params[:page] || 1,
  per_page: 20
})
```

## 9. Performance Optimization

### MongoDB Indexes

```ruby
# Essential indexes for the Product model
class Product
  # Single field indexes
  index({ name: 1 })              # For name sorting/filtering
  index({ category: 1 })          # For category filtering
  index({ brand: 1 })             # For brand filtering
  index({ price: 1 })             # For price sorting/filtering
  index({ rating: -1 })           # For rating sorting (desc)
  index({ created_at: -1 })       # For date sorting (desc)
  index({ is_active: 1 })         # For active filtering
  index({ is_featured: 1 })       # For featured filtering
  index({ stock_count: 1 })       # For stock filtering

  # Compound indexes for common filter combinations
  index({ is_active: 1, is_featured: 1, rating: -1 })
  index({ category: 1, is_active: 1, price: 1 })
  index({ brand: 1, is_active: 1, rating: -1 })
  index({ is_active: 1, stock_count: 1, created_at: -1 })

  # Text search index with weights
  index({
    name: 'text',
    description: 'text',
    brand: 'text',
    tags: 'text'
  }, {
    weights: { name: 10, brand: 5, tags: 3, description: 1 }
  })
end
```

### Search Performance Tips

1. **Use text indexes** when available (faster than regex)
2. **Create compound indexes** for common filter combinations
3. **Limit searchable fields** to avoid slow regex operations
4. **Use exact matches** when possible
5. **Monitor slow queries** with MongoDB profiler

## 10. Advanced MongoDB Features

### Text Search with Weights

```ruby
# The text index weights prioritize matches:
# name: 10x weight (most important)
# brand: 5x weight
# tags: 3x weight
# description: 1x weight (least important)

Product.search_with_filters({ query: "gaming laptop" })
# Will prioritize products with "gaming laptop" in name over description
```

### Aggregation Pipeline (Future Enhancement)

```ruby
# Example of advanced aggregation for analytics
def self.category_stats
  collection.aggregate([
    { '$match': { is_active: true } },
    { '$group': {
        _id: '$category',
        count: { '$sum': 1 },
        avg_price: { '$avg': '$price' },
        avg_rating: { '$avg': '$rating' }
      }
    },
    { '$sort': { count: -1 } }
  ])
end
```

## 11. Testing Examples

### RSpec Tests

```ruby
# spec/models/product_spec.rb
RSpec.describe Product, type: :model do
  describe '.search_with_filters' do
    let!(:gaming_laptop) { create(:product, name: 'Gaming Laptop', category: 'Electronics') }
    let!(:office_laptop) { create(:product, name: 'Office Laptop', category: 'Electronics') }

    it 'searches by query' do
      results = Product.search_with_filters(query: 'gaming')
      expect(results).to include(gaming_laptop)
      expect(results).not_to include(office_laptop)
    end

    it 'filters by category' do
      results = Product.search_with_filters(filter: { category: 'Electronics' })
      expect(results).to include(gaming_laptop, office_laptop)
    end

    it 'combines search and filters' do
      results = Product.search_with_filters(
        query: 'laptop',
        filter: { category: 'Electronics' }
      )
      expect(results).to include(gaming_laptop, office_laptop)
    end
  end
end
```

## 12. Migration from Simple Search

### Before (Simple MongoDB search)

```ruby
# Old approach
def self.search(query)
  if query.present?
    where('$text' => { '$search' => query })
  else
    all
  end
end
```

### After (SOLID MongoDB search)

```ruby
# New approach - much more powerful
Product.search_with_filters({
  query: "gaming laptop",
  filter: {
    is_active: true,
    price: { gte: 500, lte: 2000 },
    rating: { gte: 4.0 }
  },
  sort: ["is_featured:desc", "rating:desc"],
  page: 1,
  per_page: 12
})
```

This example demonstrates a complete, production-ready MongoDB search implementation that follows SOLID principles and provides powerful search capabilities using MongoDB's native features.

## 13. Comparison: MongoDB vs Elasticsearch

### When to Use MongoDB Search (This Implementation)

- ✅ Simple to medium complexity search requirements
- ✅ Existing MongoDB infrastructure
- ✅ Lower operational complexity
- ✅ Good performance for small to medium datasets
- ✅ Quick implementation and deployment

### When to Upgrade to Elasticsearch

- ⚠️ Complex relevance scoring requirements
- ⚠️ Very large datasets (millions+ records)
- ⚠️ Advanced features (facets, aggregations, auto-complete)
- ⚠️ Full-text search across many fields with complex analysis
- ⚠️ High search volume with sub-second response requirements

Both implementations use the same API interface, making migration seamless when requirements grow.
