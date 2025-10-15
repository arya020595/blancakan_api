# Elasticsearch Quick Reference

## Field Configuration Quick Reference

### Required Model Methods

```ruby
# REQUIRED - Define what fields can be searched
def elasticsearch_searchable_fields
  %w[title description name]  # Text fields for search
end

# OPTIONAL - Will use Configuration defaults if not defined
def elasticsearch_sortable_fields
  %w[title status created_at updated_at _score _id]
end

def elasticsearch_text_fields_with_keywords
  %w[title status]  # Text fields that need .keyword for sorting
end

def elasticsearch_boolean_fields
  %w[is_active is_published]
end

def elasticsearch_essential_fields
  %w[_id name status cover_image]  # Always returned (like serializer)
end
```

### Configuration Defaults (Fallbacks)

```ruby
# If your model doesn't define the above methods, these are used:
sortable_fields: %w[created_at updated_at _score _id]  # Common to all models
searchable_fields: %w[]                                # EMPTY - you must define this
text_fields_with_keywords: %w[]                       # EMPTY - you must define this  
boolean_fields: []                                     # EMPTY - define if you have booleans
essential_fields: %w[_id]                             # Just ID by default
default_sort: [{ 'created_at' => { 'order' => 'desc' } }]
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
    
    # Keyword exact match  
    status: "published",
    
    # Array inclusion (OR logic)
    category_ids: ["id1", "id2"],
    
    # Date range
    created_at: {
      gte: "2024-01-01",
      lte: "2024-12-31"
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

# Default if not specified
[{ 'created_at' => { 'order' => 'desc' } }]
```

### Pagination
```ruby
{
  page: 2,      # Page number (default: 1)
  per_page: 20  # Items per page (default: 10)
}
```

## Complete API Endpoint Example

```bash
# The endpoint that started it all:
GET /api/v1/admin/events?query=workshop&filter[is_paid]=true&sort=end_date:desc&page=2&per_page=1
```

This translates to:
- Search for "workshop" in searchable fields
- Filter for paid events only
- Sort by end_date descending
- Get page 2 with 1 result per page

## Adding New Searchable Model - Checklist

- [ ] Create `app/models/concerns/elasticsearch/your_model_searchable.rb`
- [ ] Include `BaseSearchable` in the concern
- [ ] Define Elasticsearch mappings in `settings` block
- [ ] Define `as_indexed_json` method
- [ ] Define `elasticsearch_searchable_fields` (REQUIRED)
- [ ] Define other field methods as needed
- [ ] Include the concern in your model
- [ ] Test the search functionality

## Common Issues & Solutions

### "No searchable fields defined"
**Solution**: Define `elasticsearch_searchable_fields` in your model concern

### "Sort field not found"
**Solution**: Add the field to `elasticsearch_sortable_fields` or check if it needs `.keyword` suffix

### "Filter not working"
**Solution**: Ensure the field is properly mapped in Elasticsearch settings

### "Results missing expected fields"
**Solution**: Add the fields to `elasticsearch_essential_fields`

## Performance Tips

1. **Minimize essential_fields**: Only include fields needed in API responses
2. **Use keyword subfields**: For sorting text fields efficiently  
3. **Avoid database queries**: Results come directly from Elasticsearch
4. **Monitor index size**: Large essential_fields = larger responses
5. **Test with real data**: Ensure mappings work with your actual data structure
