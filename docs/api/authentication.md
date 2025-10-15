# Authentication & Authorization

## Overview

The Blancakan API uses JWT (JSON Web Tokens) for authentication and a role-based permission system for authorization.

## Authentication Flow

### 1. User Registration

**Endpoint**: `POST /auth/register`

**Request Body**:

```json
{
  "user": {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123",
    "role_id": "6873de246522e4578b197cd2"
  }
}
```

**Success Response**:

```json
{
  "status": "success",
  "message": "Registration successful",
  "data": {
    "id": "6873de246522e4578b197cd1",
    "email": "john@example.com",
    "name": "John Doe",
    "authorization": "Bearer eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

### 2. User Sign In

**Endpoint**: `POST /auth/sign_in`

**Request Body**:

```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Success Response**:

```json
{
  "status": "success",
  "message": "Sign in successful",
  "data": {
    "id": "6873de246522e4578b197cd1",
    "email": "john@example.com",
    "name": "John Doe",
    "authorization": "Bearer eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

### 3. User Sign Out

**Endpoint**: `POST /auth/sign_out`

**Headers**:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

**Success Response**:

```json
{
  "status": "success",
  "message": "Successfully signed out",
  "data": {
    "message": "Successfully signed out"
  }
}
```

## JWT Token Configuration

### Token Expiration

JWT tokens expire based on the `JWT_EXPIRY_HOURS` environment variable:

- **Development**: 24 hours (default)
- **Production**: 1 hour (recommended)
- **Test**: 1 hour

### Environment Configuration

```bash
# .env.development
JWT_EXPIRY_HOURS=24

# .env.production
JWT_EXPIRY_HOURS=1
```

### Token Structure

JWT tokens contain the following payload:

```json
{
  "user_id": "6873de246522e4578b197cd1",
  "exp": 1640995200
}
```

## Authorization System

### Role-Based Access Control (RBAC)

The API implements a role-based permission system with the following roles:

#### Available Roles

1. **Super Admin**

   - Full access to all resources and actions
   - Can manage users, roles, and permissions

2. **Admin**

   - Can manage users and read events
   - Limited administrative access

3. **Organizer**

   - Can manage their own events
   - Can create, update, and delete owned events

4. **Premium Organizer**
   - Extended organizer capabilities
   - Can create tickets and manage events

### Permission Structure

Permissions are defined with:

- **Action**: `read`, `create`, `update`, `destroy`, `manage`
- **Subject Class**: `User`, `Event`, `Category`, etc.
- **Conditions**: Optional conditions for scoped permissions

Example permission:

```json
{
  "action": "update",
  "subject_class": "Event",
  "conditions": { "user_id": "user.id" }
}
```

### Using Authorization Headers

Include the JWT token in all authenticated requests:

```bash
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..." \
     http://localhost:3000/api/v1/admin/users
```

## Error Responses

### Authentication Errors

**401 Unauthorized**:

```json
{
  "status": "error",
  "message": "Invalid email or password",
  "errors": "Invalid email or password"
}
```

**403 Forbidden**:

```json
{
  "status": "error",
  "message": "Access denied",
  "errors": "You don't have permission to access this resource"
}
```

### Token Expiration

When a token expires, you'll receive:

```json
{
  "status": "error",
  "message": "Token expired",
  "errors": "Your session has expired. Please sign in again."
}
```

## Security Best Practices

1. **Store tokens securely** - Use secure storage on client side
2. **Use HTTPS** - Always use HTTPS in production
3. **Token expiration** - Short-lived tokens with refresh mechanism
4. **Logout handling** - Clear tokens on client logout
5. **Rate limiting** - Implement rate limiting for auth endpoints

## Implementation Notes

### JWT Service

The JWT service handles token encoding/decoding:

```ruby
# Generate token
token = JwtService.encode(user_id: user.id.to_s)

# Decode token
payload = JwtService.decode(token)
user_id = payload['user_id']
```

### Authentication in Controllers

Controllers include authentication via concerns:

```ruby
class ApplicationController < ActionController::API
  include Authentication

  before_action :authenticate_user!, except: [:public_endpoint]
end
```

### Authorization Policies

Authorization is handled through policy objects:

```ruby
class EventPolicy < ApplicationPolicy
  def update?
    user&.admin? || (user&.organizer? && record.user == user)
  end
end
```
