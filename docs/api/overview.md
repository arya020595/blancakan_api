# API Overview

## Introduction

The Blancakan API is a RESTful web service that provides comprehensive event management functionality. This API follows clean architecture principles and implements SOLID design patterns for maintainability and scalability.

## Features

- **User Authentication**: JWT-based authentication with role-based access control
- **Event Management**: Create, read, update, and delete events with rich metadata
- **Category Management**: Hierarchical category system for event organization
- **Event Type Management**: Flexible event type categorization
- **User Management**: Complete user lifecycle management with role assignments
- **File Uploads**: Image upload support with cloud storage integration
- **Search & Filtering**: Advanced search capabilities with Elasticsearch integration
- **Pagination**: Consistent pagination across all list endpoints

## Architecture

The API is built using:

- **Ruby on Rails 7.x** - Web framework
- **MongoDB** - Primary database with Mongoid ODM
- **Elasticsearch** - Search and analytics engine
- **JWT** - Token-based authentication
- **Cloudinary** - Image storage and transformation
- **Sidekiq** - Background job processing

## API Versioning

The API uses URL-based versioning:

- Current version: `v1`
- Base URL: `/api/v1/`

## Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## Response Format

All API responses follow a consistent format:

```json
{
  "status": "success|error",
  "message": "Human-readable message",
  "data": {}, // Response data (for success responses)
  "errors": [] // Error details (for error responses)
}
```

## Rate Limiting

- **Authenticated requests**: 1000 requests per hour
- **Unauthenticated requests**: 100 requests per hour

## Pagination

List endpoints support pagination with the following parameters:

- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 20, max: 100)

Pagination metadata is included in the response:

```json
{
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20,
    "next_page": 2,
    "prev_page": null
  }
}
```

## Error Handling

The API uses standard HTTP status codes:

- `200` - Success
- `201` - Created
- `204` - No Content
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Unprocessable Entity
- `429` - Too Many Requests
- `500` - Internal Server Error

Error responses include detailed information:

```json
{
  "status": "error",
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "code": "blank",
      "message": "can't be blank"
    }
  ]
}
```

## Data Types

### Common Data Types

- **ObjectId**: MongoDB ObjectId (24-character hexadecimal string)
- **DateTime**: ISO 8601 format (`2023-12-01T10:30:00Z`)
- **Boolean**: `true` or `false`
- **Array**: JSON array notation
- **Object**: JSON object notation

### Status Values

- **Event Status**: `draft`, `published`, `cancelled`, `completed`
- **User Status**: `active`, `inactive`, `suspended`
- **Category Status**: `true` (active), `false` (inactive)

## SDKs and Tools

### Postman Collection

Import our Postman collection for easy API testing:

- [Download Postman Collection](../postman/Blancakan_API.postman_collection.json)

### OpenAPI Specification

The complete API specification is available in OpenAPI 3.0 format:

- [View Swagger/OpenAPI Spec](../../swagger/v1/swagger.yaml)

### Testing Environment

#### Development

- **Base URL**: `http://localhost:3000`
- **Database**: Local MongoDB instance
- **Features**: Debug logging, detailed error messages

#### Staging

- **Base URL**: `https://api-staging.blancakan.com`
- **Database**: Staging MongoDB cluster
- **Features**: Production-like environment for testing

#### Production

- **Base URL**: `https://api.blancakan.com`
- **Database**: Production MongoDB cluster
- **Features**: Optimized performance, minimal logging

## Getting Started

1. **Authentication**: Register a user account or sign in to get a JWT token
2. **Explore**: Use the interactive API documentation at `/swagger`
3. **Build**: Start integrating the API into your application

## Support

- **Documentation**: This documentation site
- **API Reference**: Detailed endpoint documentation
- **Examples**: Code samples and use cases
- **Issues**: Report bugs and request features via GitHub

## Changelog

### v1.0.0 (Current)

- Initial API release
- User authentication and management
- Event CRUD operations
- Category and event type management
- File upload support
- Search functionality
