# MongoDB Search Quick Reference

## Field Configuration Quick Reference

### Required Model Methods

```ruby
# REQUIRED - Define what fields can be searched
def mongodb_searchable_fields
  %w[name description title]  # Text fields for search
end

# OPTIONAL - Will use Configuration defaults if not defined
def mongodb_sortable_fields
  %w[name status created_at updated_at _id]
end

def mongodb_text_fields
  %w[name description]  # Only if you have text indexes
end

def mongodb_boolean_fields
  %w[is_active is_published]
end

def mongodb_filterable_fields
  %w[name status is_active created_at updated_at]
end

def mongodb_default_sort
  { created_at: -1 }  # MongoDB format: 1=asc, -1=desc
end
```

### Configuration Defaults (Fallbacks)

```ruby
# If your model doesn't define the above methods, these are used:
sortable_fields: %w[created_at updated_at _id]      # Common to all models
searchable_fields: %w[]                             # EMPTY - you must define this
text_fields: %w[]                                   # EMPTY - define if you have text indexes
boolean_fields: []                                  # EMPTY - define if you have booleans
filterable_fields: %w[created_at updated_at]        # Basic timestamp filtering
default_sort: { created_at: -1 }                    # Newest first
```

## Search Parameter Examples

### Basic Search

```ruby
Model.search_with_filters({ query: "search term" })
```

### Filters

```ruby
{
  filter: {
    # Boolean filter
    is_active: true,

    # Exact match
    status: "published",

    # Array inclusion (OR logic)
    categories: ["cat1", "cat2"],

    # Date/numeric range
    created_at: {
      gte: "2024-01-01",
      lte: "2024-12-31"
    },

    price: {
      gte: 100,
      lt: 500
    }
  }
}
```

### Sorting

```ruby
# Single sort
{ sort: "created_at:desc" }

# Multiple sorts
{ sort: ["status:asc", "created_at:desc"] }

# MongoDB format in model config
{ status: 1, created_at: -1 }  # 1=asc, -1=desc
```

### Pagination

```ruby
{
  page: 2,      # Page number (default: 1)
  per_page: 20  # Items per page (default: 10)
}
```

## API Endpoint Examples

```bash
# Basic search
GET /api/v1/admin/event_types?query=workshop

# With filters
GET /api/v1/admin/event_types?filter[is_active]=true&filter[name]=Conference

# With sorting
GET /api/v1/admin/event_types?sort=name:asc

# Multiple sorts
GET /api/v1/admin/event_types?sort[]=sort_order:asc&sort[]=name:asc

# With pagination
GET /api/v1/admin/event_types?page=2&per_page=5

# Complete example
GET /api/v1/admin/event_types?query=workshop&filter[is_active]=true&sort=sort_order:asc&page=1&per_page=10
```

## Adding New Searchable Model - Checklist

- [ ] Create `app/models/concerns/mongodb_search/your_model_searchable.rb`
- [ ] Include `BaseSearchable` in the concern
- [ ] Define `mongodb_searchable_fields` (REQUIRED)
- [ ] Define other field methods as needed
- [ ] Include the concern in your model
- [ ] Update service to use `search_with_filters(params)`
- [ ] Update controller to pass `search_params`
- [ ] Add `search_params` method to controller
- [ ] Test the search functionality
- [ ] Add MongoDB indexes for performance

## MongoDB Indexes Recommendations

```ruby
class YourModel
  include Mongoid::Document

  # Text search index (enables $text search)
  index({ name: 'text', description: 'text' })

  # Single field indexes for sorting/filtering
  index({ name: 1 })
  index({ status: 1 })
  index({ is_active: 1 })
  index({ created_at: -1 })

  # Compound indexes for common filter combinations
  index({ is_active: 1, status: 1, created_at: -1 })
  index({ category: 1, is_active: 1 })
end
```

## Performance Tips

1. **Add text indexes**: For fields in `mongodb_text_fields`
2. **Create compound indexes**: For common filter combinations
3. **Limit searchable_fields**: Avoid too many regex queries
4. **Use text search**: When you have text indexes (faster than regex)
5. **Monitor performance**: Use MongoDB profiling tools
6. **Avoid deep pagination**: Large page numbers can be slow

## Common Issues & Solutions

### "No searchable fields defined"

**Solution**: Define `mongodb_searchable_fields` in your model concern

### "Sort field not allowed"

**Solution**: Add the field to `mongodb_sortable_fields`

### "Filter not working"

**Solution**: Add the field to `mongodb_filterable_fields`

### "Text search not working"

**Solution**: Ensure you have text indexes and the fields are in `mongodb_text_fields`

### "Slow search performance"

**Solution**: Add appropriate MongoDB indexes

## MongoDB vs Elasticsearch Quick Comparison

| Feature            | MongoDB Search         | Elasticsearch               |
| ------------------ | ---------------------- | --------------------------- |
| **Setup**          | ✅ Simple              | ⚠️ Complex                  |
| **Performance**    | ✅ Good (small/medium) | ✅ Excellent (large)        |
| **Search Quality** | ⚠️ Basic               | ✅ Advanced                 |
| **Features**       | ⚠️ Basic CRUD          | ✅ Advanced search          |
| **Maintenance**    | ✅ Low                 | ⚠️ High                     |
| **Use Case**       | Simple search needs    | Complex search requirements |

Choose MongoDB search for simpler use cases, Elasticsearch for advanced search requirements.
