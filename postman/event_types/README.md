# EventType API - Postman Collection

This folder contains Postman collection for testing the EventType API with MongoDB search functionality.

## Files

- **`Event_Types_MongoDB_Search.postman_collection.json`** - Complete EventType API collection

## Features Tested

### MongoDB Search Implementation

- Text search using MongoDB `$text` search or regex fallback
- Boolean filtering (active/inactive)
- Exact match filtering
- Range filtering (sort_order)
- Single and multiple field sorting
- Pagination support

### API Endpoints Covered

- CRUD operations (Create, Read, Update, Delete)
- Search functionality
- Filtering capabilities
- Sorting options
- Pagination

## Import Instructions

1. Open Postman
2. Click "Import" → "Upload Files"
3. Select `Event_Types_MongoDB_Search.postman_collection.json`
4. Import the shared environment from `../shared/Blancakan_API_Development.postman_environment.json`

## Quick Test Sequence

1. **Get All Event Types** - See available data
2. **Basic Text Search** - Test MongoDB search
3. **Filter Active Only** - Test filtering
4. **Sort by Name** - Test sorting
5. **Combined Features** - Test search + filter + sort + pagination

## MongoDB Search Features

- **Text Search**: `?query=workshop`
- **Boolean Filter**: `?filter[is_active]=true`
- **Range Filter**: `?filter[sort_order][gte]=2&filter[sort_order][lte]=4`
- **Sorting**: `?sort=name:asc` or `?sort[]=sort_order:asc&sort[]=name:asc`
- **Pagination**: `?page=1&per_page=5`

## Example API Calls

```bash
# Basic search
GET /api/v1/admin/event_types?query=workshop

# Combined features
GET /api/v1/admin/event_types?query=workshop&filter[is_active]=true&sort=name:asc&page=1&per_page=5
```
