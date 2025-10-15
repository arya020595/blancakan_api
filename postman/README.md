# Postman Collections for Blancakan API

This directory contains organized Postman collections for testing the Blancakan API endpoints and search functionality.

## Directory Structure

```
postman/
├── shared/                     # Shared resources
│   ├── environments/          # Environment files
│   └── README.md
├── event_types/              # Event Types API collections
│   ├── Event_Types_MongoDB_Search.postman_collection.json
│   └── README.md
├── events/                   # Events API collections
│   ├── Events_Elasticsearch_Search.postman_collection.json
│   └── README.md
└── README.md                 # This file
```

## Collections by Model

### Event Types (MongoDB Search)

- **Location**: `event_types/`
- **Collection**: `Event_Types_MongoDB_Search.postman_collection.json`
- **Features**: MongoDB native search, filtering, sorting, pagination
- **Best for**: Simple search operations on smaller datasets

### Events (Elasticsearch Search)

- **Location**: `events/`
- **Collection**: `Events_Elasticsearch_Search.postman_collection.json`
- **Features**: Advanced Elasticsearch search, complex filtering, relevance scoring, fuzzy matching
- **Best for**: Complex search operations on large datasets

## Shared Resources

### Environment Files

- **Location**: `shared/`
- **File**: `Blancakan_API_Development.postman_environment.json`
- **Contains**: Base URLs, authentication tokens, common variables

## Search Implementation Comparison

| Feature           | Event Types (MongoDB) | Events (Elasticsearch)      |
| ----------------- | --------------------- | --------------------------- |
| Text Search       | MongoDB text indexes  | Multi-match queries         |
| Fuzzy Search      | Limited               | Advanced fuzzy matching     |
| Relevance Scoring | Basic                 | Advanced scoring algorithms |
| Complex Filters   | Basic operators       | Rich query DSL              |
| Performance       | Good for small data   | Optimized for large data    |
| Setup Complexity  | Low                   | Medium                      |

## Usage Instructions

### 1. Import Collections

Import the specific collection you need:

- For Event Types: Import from `event_types/` folder
- For Events: Import from `events/` folder

### 2. Import Environment

Import the shared environment file from `shared/` folder

### 3. Configure Environment

Update variables in the environment:

- `base_url`: Your Rails server URL
- Model-specific IDs for testing operations

### 4. Test Progressive Complexity

Each collection is organized from simple to complex:

1. Basic CRUD operations
2. Simple search functionality
3. Advanced filtering
4. Complex combined scenarios

## Features Tested

### Common Features (Both Collections)

- **CRUD Operations**: Create, Read, Update, Delete
- **Pagination**: Page-based with configurable sizes
- **Sorting**: Single and multiple field sorting
- **Basic Filtering**: Status, boolean, and exact match filters

### MongoDB-Specific Features (Event Types)

- **Text Search**: Using MongoDB text indexes
- **Simple Filtering**: Basic operators and conditions
- **Performance**: Optimized for straightforward queries

### Elasticsearch-Specific Features (Events)

- **Advanced Search**: Multi-field search with boosting
- **Fuzzy Matching**: Typo tolerance and partial matching
- **Relevance Scoring**: Sort by search relevance
- **Complex Filtering**: Range, array, and nested filters
- **Rich Query DSL**: Advanced query combinations

## Architecture Testing

These collections validate the SOLID search architecture implementations:

- **SearchFacade**: Main search orchestrator
- **QueryBuilder**: Text search logic
- **FilterBuilder**: Filter processing
- **SortBuilder**: Sort criteria handling
- **Configuration**: Centralized defaults
- **Results Formatting**: Consistent response structure

## Development Workflow

1. **Choose Collection**: Select based on your model and search complexity needs
2. **Start Simple**: Begin with basic CRUD operations
3. **Add Search**: Test text search functionality
4. **Layer Complexity**: Add filters, sorting, pagination
5. **Validate Integration**: Test complex combined scenarios
6. **Performance Test**: Verify response times and accuracy

This organization allows for focused testing of specific search implementations while maintaining consistency across the API.
