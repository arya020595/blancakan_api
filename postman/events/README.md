# Events Collection - Elasticsearch Search

This collection demonstrates the complete Events API with advanced Elasticsearch search capabilities for the Blancakan API.

## Collection Features

### 1. CRUD Operations
Basic Create, Read, Update, Delete operations for events.

### 2. Elasticsearch Search Features
- **Text Search**: Multi-field search with fuzzy matching across title, description, and other searchable fields
- **Relevance Scoring**: Sort by Elasticsearch `_score` for most relevant results
- **Fuzzy Matching**: Typo tolerance in search queries

### 3. Advanced Filtering
- **Boolean Filters**: `is_paid` (true/false)
- **Exact Match**: `status`, `location_type`
- **Range Filters**: Date ranges using `gte`, `lte` operators
- **Array Filters**: Multiple category IDs
- **Combined Filters**: Mix multiple filter types

### 4. Flexible Sorting
- **Single Field**: Sort by title, date, payment status
- **Multiple Fields**: Primary and secondary sort criteria
- **Relevance**: Sort by Elasticsearch score
- **Direction**: Ascending (`asc`) or descending (`desc`)

### 5. Pagination
- **Page-based**: Use `page` and `per_page` parameters
- **Flexible Size**: Support for different page sizes
- **Performance**: Optimized for large datasets

## Usage Examples

### Basic Search
```
GET /api/v1/admin/events?query=workshop
```

### Filtered Search
```
GET /api/v1/admin/events?query=ruby&filter[is_paid]=true&filter[status]=published
```

### Date Range Filter
```
GET /api/v1/admin/events?filter[start_date][gte]=2025-09-01&filter[start_date][lte]=2025-12-31
```

### Multiple Sort Criteria
```
GET /api/v1/admin/events?sort[]=is_paid:desc&sort[]=start_date:asc
```

### Complete Example
```
GET /api/v1/admin/events?query=ruby&filter[is_paid]=true&filter[status]=published&sort[]=_score:desc&sort[]=start_date:asc&page=1&per_page=5
```

## Filter Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `query` | string | Text search across multiple fields | `ruby`, `workshop` |
| `filter[is_paid]` | boolean | Filter by payment type | `true`, `false` |
| `filter[status]` | string | Filter by event status | `published`, `draft` |
| `filter[location_type]` | string | Filter by location type | `online`, `offline` |
| `filter[category_ids][]` | array | Filter by category IDs | Multiple values |
| `filter[start_date][gte]` | date | Events starting on/after date | `2025-09-01` |
| `filter[start_date][lte]` | date | Events starting on/before date | `2025-12-31` |

## Sort Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `sort` | Single sort criterion | `start_date:desc` |
| `sort[]` | Multiple sort criteria | `sort[]=is_paid:desc&sort[]=start_date:asc` |

Available sort fields:
- `title` - Event title
- `start_date` - Event start date
- `is_paid` - Payment status
- `status` - Event status
- `_score` - Elasticsearch relevance score

## Response Format

All responses include:
- **data**: Array of event objects
- **pagination**: Page information (current_page, total_pages, total_count, per_page)
- **search_meta**: Elasticsearch metadata (took, hits, etc.)

```json
{
  "data": [...],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 23,
    "per_page": 5
  },
  "search_meta": {
    "took": 15,
    "total_hits": 23,
    "max_score": 1.2
  }
}
```

## Architecture

This collection tests the SOLID Elasticsearch implementation with:

- **SearchFacade**: Main orchestrator for search operations
- **QueryBuilder**: Handles text search and multi_match queries
- **FilterBuilder**: Processes all filter parameters
- **SortBuilder**: Manages single and multiple sort criteria
- **Configuration**: Centralized search defaults and field mappings
- **PaginatedElasticsearchResults**: Formats paginated responses

## Setup

1. Import the collection and environment files
2. Update variables:
   - `base_url`: Your Rails server URL (default: http://localhost:3000)
   - `event_id`: Valid event ID from your database
   - `category_id`: Valid category ID from your database
3. Ensure Elasticsearch is running and indexed with event data
4. Run requests to test the search functionality

## Testing Strategy

The collection is organized by feature complexity:
1. Start with basic CRUD operations
2. Test simple text searches
3. Add filtering capabilities
4. Test sorting options
5. Verify pagination
6. Test complex combined scenarios

This structure allows for progressive testing and validation of the Elasticsearch search implementation.
