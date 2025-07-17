# API Endpoints Reference

## Table of Contents

- [Authentication Endpoints](#authentication-endpoints)
- [Admin Endpoints](#admin-endpoints)
  - [Categories Management](#categories-management)
  - [Events Management](#events-management)
  - [Event Types Management](#event-types-management)
  - [Users Management](#users-management)
- [Public Endpoints](#public-endpoints)

## Base URLs

| Environment | URL                                 |
| ----------- | ----------------------------------- |
| Development | `http://localhost:3000`             |
| Staging     | `https://api-staging.blancakan.com` |
| Production  | `https://api.blancakan.com`         |

---

## Authentication Endpoints

### POST /auth

Register a new user account.

**Description**: Create a new user account with optional role assignment.

**Request Body**:

```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "password_confirmation": "securepassword"
}
```

**Response (200 - Success)**:

```json
{
  "status": "success",
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@example.com",
      "created_at": "2023-12-01T10:30:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Response (422 - Validation Error)**:

```json
{
  "status": "error",
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "has already been taken"
    }
  ]
}
```

---

### POST /auth/sign_in

Authenticate user and receive JWT token.

**Description**: Sign in with email and password to receive an authentication token.

**Request Body**:

```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response (200 - Success)**:

```json
{
  "status": "success",
  "message": "User signed in successfully",
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@example.com",
      "role": {
        "id": "507f1f77bcf86cd799439012",
        "name": "user"
      }
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Response (401 - Invalid Credentials)**:

```json
{
  "status": "error",
  "message": "Invalid email or password"
}
```

---

### DELETE /auth/sign_out

Sign out current user.

**Description**: Invalidate the current JWT token.

**Headers**:

```
Authorization: Bearer <your-jwt-token>
```

**Response (200 - Success)**:

```json
{
  "status": "success",
  "message": "User signed out successfully"
}
```

---

## Admin Endpoints

**Note**: All admin endpoints require authentication and appropriate permissions.

### Categories Management

#### GET /api/v1/admin/categories

Retrieve all categories.

**Description**: Get a list of all categories in the system.

**Headers**:

```
Authorization: Bearer <your-jwt-token>
```

**Response (200 - Success)**:

```json
{
  "status": "success",
  "message": "Categories retrieved successfully",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Technology",
      "description": "Technology related events",
      "parent_id": null,
      "status": true,
      "created_at": "2023-12-01T10:30:00Z",
      "updated_at": "2023-12-01T10:30:00Z"
    }
  ]
}
```

---

#### POST /api/v1/admin/categories

Create a new category.

**Description**: Create a new category for organizing events.

**Headers**:

```
Authorization: Bearer <your-jwt-token>
```

**Request Body**:

```json
{
  "name": "Technology",
  "description": "Technology related events",
  "parent_id": null
}
```

**Response (201 - Created)**:

```json
{
  "status": "success",
  "message": "Category created successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "name": "Technology",
    "description": "Technology related events",
    "parent_id": null,
    "status": true,
    "created_at": "2023-12-01T10:30:00Z",
    "updated_at": "2023-12-01T10:30:00Z"
  }
}
```

---

#### GET /api/v1/admin/categories/{id}

Retrieve a specific category.

**Description**: Get details of a specific category by ID.

**Headers**:

```
Authorization: Bearer <your-jwt-token>
```

**Parameters**:

- `id` (path) - Category ID

**Response (200 - Success)**:

```json
{
  "status": "success",
  "message": "Category found",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "name": "Technology",
    "description": "Technology related events",
    "parent_id": null,
    "status": true,
    "created_at": "2023-12-01T10:30:00Z",
    "updated_at": "2023-12-01T10:30:00Z"
  }
}
```

**Response (404 - Not Found)**:

```json
{
  "status": "error",
  "message": "Category not found"
}
```

---

#### PUT /api/v1/admin/categories/{id}

Update a category.

**Description**: Update an existing category's information.

**Headers**:

```
Authorization: Bearer <your-jwt-token>
```

**Parameters**:

- `id` (path) - Category ID

**Request Body**:

```json
{
  "name": "Updated Technology",
  "description": "Updated description for technology events"
}
```

**Response (200 - Success)**:

```json
{
  "status": "success",
  "message": "Category updated successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "name": "Updated Technology",
    "description": "Updated description for technology events",
    "parent_id": null,
    "status": true,
    "created_at": "2023-12-01T10:30:00Z",
    "updated_at": "2023-12-01T11:30:00Z"
  }
}
```

---

#### DELETE /api/v1/admin/categories/{id}

Delete a category.

**Description**: Remove a category from the system.

**Headers**:

```
Authorization: Bearer <your-jwt-token>
```

**Parameters**:

- `id` (path) - Category ID

**Response (204 - No Content)**:
No response body.

---

### Events Management

#### GET /api/v1/admin/events

Retrieve all events.

**Description**: Get a paginated list of all events with optional filtering.

**Headers**:

```
Authorization: Bearer <your-jwt-token>
```

**Query Parameters**:

- `page` (integer, optional) - Page number (default: 1)
- `per_page` (integer, optional) - Items per page (default: 20, max: 100)
- `status` (string, optional) - Filter by event status
- `category_id` (string, optional) - Filter by category
- `search` (string, optional) - Search query

**Response (200 - Success)**:

```json
{
  "status": "success",
  "message": "Events retrieved successfully",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "title": "Tech Conference 2024",
      "description": "Annual technology conference",
      "start_date": "2024-03-15T09:00:00Z",
      "end_date": "2024-03-17T18:00:00Z",
      "location": "Convention Center",
      "status": "published",
      "organizer_id": "507f1f77bcf86cd799439012",
      "event_type_id": "507f1f77bcf86cd799439013",
      "category_ids": ["507f1f77bcf86cd799439014"],
      "image_url": "https://example.com/image.jpg",
      "created_at": "2023-12-01T10:30:00Z",
      "updated_at": "2023-12-01T10:30:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per_page": 20
  }
}
```

---

#### POST /api/v1/admin/events

Create a new event.

**Description**: Create a new event with complete details.

**Headers**:

```
Authorization: Bearer <your-jwt-token>
Content-Type: multipart/form-data
```

**Request Body** (multipart/form-data):

```
title: "Tech Conference 2024"
description: "Annual technology conference"
start_date: "2024-03-15T09:00:00Z"
end_date: "2024-03-17T18:00:00Z"
location: "Convention Center"
event_type_id: "507f1f77bcf86cd799439013"
category_ids[]: "507f1f77bcf86cd799439014"
image: (file upload)
```

**Response (201 - Created)**:

```json
{
  "status": "success",
  "message": "Event created successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "title": "Tech Conference 2024",
    "description": "Annual technology conference",
    "start_date": "2024-03-15T09:00:00Z",
    "end_date": "2024-03-17T18:00:00Z",
    "location": "Convention Center",
    "status": "draft",
    "organizer_id": "507f1f77bcf86cd799439012",
    "event_type_id": "507f1f77bcf86cd799439013",
    "category_ids": ["507f1f77bcf86cd799439014"],
    "image_url": "https://cloudinary.com/image.jpg",
    "created_at": "2023-12-01T10:30:00Z",
    "updated_at": "2023-12-01T10:30:00Z"
  }
}
```

---

### Event Types Management

#### GET /api/v1/admin/event_types

Retrieve all event types.

**Description**: Get a list of all event types in the system.

**Headers**:

```
Authorization: Bearer <your-jwt-token>
```

**Response (200 - Success)**:

```json
{
  "status": "success",
  "message": "Event types retrieved successfully",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Conference",
      "description": "Large scale professional gathering",
      "status": true,
      "created_at": "2023-12-01T10:30:00Z",
      "updated_at": "2023-12-01T10:30:00Z"
    }
  ]
}
```

---

### Users Management

#### GET /api/v1/admin/users

Retrieve all users.

**Description**: Get a paginated list of all users in the system.

**Headers**:

```
Authorization: Bearer <your-jwt-token>
```

**Query Parameters**:

- `page` (integer, optional) - Page number
- `per_page` (integer, optional) - Items per page
- `search` (string, optional) - Search query

**Response (200 - Success)**:

```json
{
  "status": "success",
  "message": "Users retrieved successfully",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "email": "user@example.com",
      "role": {
        "id": "507f1f77bcf86cd799439012",
        "name": "user"
      },
      "created_at": "2023-12-01T10:30:00Z",
      "updated_at": "2023-12-01T10:30:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 200,
    "per_page": 20
  }
}
```

---

#### GET /api/v1/admin/users/:id

Retrieve a specific user.

**Response**:

```json
{
  "status": "success",
  "message": "User found",
  "data": {
    "id": "string",
    "name": "string",
    "email": "string",
    "role_id": "string",
    "created_at": "datetime",
    "updated_at": "datetime"
  }
}
```

---

#### POST /api/v1/admin/users

Create a new user.

**Request Body**:

```json
{
  "user": {
    "name": "string",
    "email": "string",
    "password": "string",
    "password_confirmation": "string",
    "role_id": "string"
  }
}
```

**Responses**:

- `201` - User created successfully
- `422` - Validation errors

---

#### PUT /api/v1/admin/users/:id

Update an existing user.

**Request Body**:

```json
{
  "user": {
    "name": "string",
    "email": "string",
    "password": "string", // optional
    "password_confirmation": "string", // optional
    "role_id": "string"
  }
}
```

**Responses**:

- `200` - User updated successfully
- `422` - Validation errors
- `404` - User not found

---

#### DELETE /api/v1/admin/users/:id

Delete a user.

**Responses**:

- `204` - User deleted successfully
- `404` - User not found

---

### Events Management

#### GET /api/v1/admin/events

Retrieve all events with pagination.

**Query Parameters**:

- `page` (integer, optional) - Page number
- `per_page` (integer, optional) - Items per page
- `query` (string, optional) - Search query

**Response**:

```json
{
  "status": "success",
  "message": "Events fetched successfully",
  "data": [
    {
      "_id": "string",
      "title": "string",
      "description": "string",
      "location": "object",
      "start_date": "date",
      "start_time": "datetime",
      "end_date": "date",
      "end_time": "datetime",
      "timezone": "string",
      "status": "string",
      "is_paid": "boolean",
      "organizer_id": "string",
      "event_type_id": "string",
      "category_ids": ["string"],
      "created_at": "datetime",
      "updated_at": "datetime"
    }
  ]
}
```

---

#### GET /api/v1/admin/events/:id

Retrieve a specific event.

---

#### POST /api/v1/admin/events

Create a new event.

**Request Body**:

```json
{
  "event": {
    "title": "string",
    "description": "string",
    "start_date": "date",
    "start_time": "datetime",
    "end_date": "date",
    "end_time": "datetime",
    "location_type": "string", // "online" or "offline"
    "location": {
      "city": "string",
      "state": "string",
      "address": "string"
    },
    "timezone": "string",
    "event_type_id": "string",
    "organizer_id": "string",
    "cover_image_url": "string", // optional
    "status": "string", // "draft", "published", "cancelled"
    "is_paid": "boolean",
    "category_ids": ["string"]
  }
}
```

**Responses**:

- `201` - Event created successfully
- `422` - Validation errors

---

#### PUT /api/v1/admin/events/:id

Update an existing event.

**Request Body**: Same as POST /api/v1/admin/events

**Responses**:

- `200` - Event updated successfully
- `422` - Validation errors
- `404` - Event not found

---

#### DELETE /api/v1/admin/events/:id

Delete an event.

**Responses**:

- `204` - Event deleted successfully
- `404` - Event not found

---

### Categories Management

#### GET /api/v1/admin/categories

Retrieve all categories.

**Response**:

```json
{
  "status": "success",
  "message": "Categories fetched successfully",
  "data": [
    {
      "_id": "string",
      "name": "string",
      "description": "string",
      "parent_id": "string", // nullable
      "status": "boolean",
      "created_at": "datetime",
      "updated_at": "datetime"
    }
  ]
}
```

---

#### GET /api/v1/admin/categories/:id

Retrieve a specific category.

---

#### POST /api/v1/admin/categories

Create a new category.

**Request Body**:

```json
{
  "category": {
    "name": "string",
    "description": "string",
    "parent_id": "string", // optional
    "is_active": "boolean" // optional, defaults to true
  }
}
```

---

#### PUT /api/v1/admin/categories/:id

Update an existing category.

---

#### DELETE /api/v1/admin/categories/:id

Delete a category.

---

### Roles Management

#### GET /api/v1/admin/roles

Retrieve all roles.

**Response**:

```json
{
  "status": "success",
  "message": "Roles fetched successfully",
  "data": [
    {
      "_id": "string",
      "name": "string",
      "description": "string",
      "created_at": "datetime",
      "updated_at": "datetime"
    }
  ]
}
```

---

#### GET /api/v1/admin/roles/:id

Retrieve a specific role.

---

#### POST /api/v1/admin/roles

Create a new role.

**Request Body**:

```json
{
  "role": {
    "name": "string",
    "description": "string"
  }
}
```

---

#### PUT /api/v1/admin/roles/:id

Update an existing role.

---

#### DELETE /api/v1/admin/roles/:id

Delete a role.

---

### Permissions Management

#### GET /api/v1/admin/permissions

Retrieve all permissions.

**Response**:

```json
{
  "status": "success",
  "message": "Permissions fetched successfully",
  "data": [
    {
      "_id": "string",
      "action": "string",
      "subject_class": "string",
      "role_id": "string",
      "conditions": "object", // optional
      "created_at": "datetime",
      "updated_at": "datetime"
    }
  ]
}
```

---

#### GET /api/v1/admin/permissions/:id

Retrieve a specific permission.

---

#### POST /api/v1/admin/permissions

Create a new permission.

**Request Body**:

```json
{
  "permission": {
    "action": "string", // "read", "create", "update", "destroy", "manage"
    "subject_class": "string", // "User", "Event", "Category", etc.
    "role_id": "string",
    "conditions": {} // optional conditions object
  }
}
```

---

#### PUT /api/v1/admin/permissions/:id

Update an existing permission.

---

#### DELETE /api/v1/admin/permissions/:id

Delete a permission.

---

## HTTP Status Codes

- `200` - OK: Request successful
- `201` - Created: Resource created successfully
- `204` - No Content: Resource deleted successfully
- `400` - Bad Request: Invalid request parameters
- `401` - Unauthorized: Authentication required
- `403` - Forbidden: Insufficient permissions
- `404` - Not Found: Resource not found
- `422` - Unprocessable Entity: Validation errors
- `500` - Internal Server Error: Server error

## Rate Limiting

API endpoints are rate limited to prevent abuse:

- **Authentication endpoints**: 5 requests per minute per IP
- **General endpoints**: 100 requests per minute per user
- **Admin endpoints**: 200 requests per minute per admin user

## Pagination

List endpoints support pagination with the following parameters:

- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 10, max: 100)

Pagination metadata is included in the response:

```json
{
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 10,
    "total_count": 100,
    "per_page": 10
  }
}
```

## Search

Search functionality is available on list endpoints using the `query` parameter:

```
GET /api/v1/admin/users?query=john@example.com
GET /api/v1/admin/events?query=conference
```

The search uses Elasticsearch for full-text search across relevant fields.
