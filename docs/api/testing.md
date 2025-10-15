# API Testing Guide

## Overview

This guide provides comprehensive instructions for testing the Blancakan API endpoints. It includes examples using different tools and programming languages.

## Table of Contents

- [Authentication Setup](#authentication-setup)
- [Testing Tools](#testing-tools)
- [Endpoint Testing Examples](#endpoint-testing-examples)
- [Error Handling](#error-handling)
- [Performance Testing](#performance-testing)
- [Automated Testing](#automated-testing)

## Authentication Setup

### Getting Started

1. **Register a new user** or **sign in** to get a JWT token
2. **Include the token** in all authenticated requests
3. **Handle token expiration** gracefully in your application

### Example: Getting an Authentication Token

```bash
# Register a new user
curl -X POST http://localhost:3000/auth \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'

# Sign in to get token
curl -X POST http://localhost:3000/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Response**:
```json
{
  "status": "success",
  "message": "User signed in successfully",
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "test@example.com"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

## Testing Tools

### 1. cURL

Basic command-line testing:

```bash
# Set your token as an environment variable
export JWT_TOKEN="your-jwt-token-here"

# Test authenticated endpoint
curl -X GET http://localhost:3000/api/v1/admin/categories \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json"
```

### 2. Postman

#### Setting up Postman Environment

1. Create a new environment called "Blancakan API"
2. Add these variables:
   - `base_url`: `http://localhost:3000`
   - `jwt_token`: (will be set automatically)

#### Pre-request Script for Authentication

```javascript
// Auto-login script for Postman
if (!pm.environment.get("jwt_token")) {
    pm.sendRequest({
        url: pm.environment.get("base_url") + "/auth/sign_in",
        method: "POST",
        header: {
            "Content-Type": "application/json"
        },
        body: {
            mode: "raw",
            raw: JSON.stringify({
                email: "test@example.com",
                password: "password123"
            })
        }
    }, function (err, response) {
        if (!err && response.code === 200) {
            const jsonData = response.json();
            pm.environment.set("jwt_token", jsonData.data.token);
        }
    });
}
```

### 3. HTTPie

User-friendly command-line HTTP client:

```bash
# Install HTTPie
pip install httpie

# Get token
http POST localhost:3000/auth/sign_in email=test@example.com password=password123

# Use token in requests
http GET localhost:3000/api/v1/admin/categories Authorization:"Bearer your-token-here"
```

### 4. JavaScript/Node.js

```javascript
const axios = require('axios');

class BlancakanAPI {
  constructor(baseURL = 'http://localhost:3000') {
    this.baseURL = baseURL;
    this.token = null;
    this.client = axios.create({
      baseURL: this.baseURL,
      timeout: 10000,
    });
  }

  async signIn(email, password) {
    try {
      const response = await this.client.post('/auth/sign_in', {
        email,
        password
      });
      
      this.token = response.data.data.token;
      this.client.defaults.headers.common['Authorization'] = `Bearer ${this.token}`;
      
      return response.data;
    } catch (error) {
      throw new Error(`Sign in failed: ${error.response?.data?.message || error.message}`);
    }
  }

  async getCategories() {
    try {
      const response = await this.client.get('/api/v1/admin/categories');
      return response.data;
    } catch (error) {
      throw new Error(`Get categories failed: ${error.response?.data?.message || error.message}`);
    }
  }

  async createEvent(eventData) {
    try {
      const formData = new FormData();
      Object.keys(eventData).forEach(key => {
        if (key === 'image' && eventData[key]) {
          formData.append('image', eventData[key]);
        } else if (Array.isArray(eventData[key])) {
          eventData[key].forEach(value => {
            formData.append(`${key}[]`, value);
          });
        } else {
          formData.append(key, eventData[key]);
        }
      });

      const response = await this.client.post('/api/v1/admin/events', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        }
      });
      
      return response.data;
    } catch (error) {
      throw new Error(`Create event failed: ${error.response?.data?.message || error.message}`);
    }
  }
}

// Usage example
async function testAPI() {
  const api = new BlancakanAPI();
  
  try {
    // Sign in
    await api.signIn('test@example.com', 'password123');
    console.log('✅ Signed in successfully');
    
    // Get categories
    const categories = await api.getCategories();
    console.log('✅ Categories retrieved:', categories.data.length);
    
    // Create an event
    const eventData = {
      title: 'Test Event',
      description: 'This is a test event',
      start_date: '2024-03-15T09:00:00Z',
      end_date: '2024-03-15T17:00:00Z',
      location: 'Test Location',
      event_type_id: 'your-event-type-id',
      category_ids: ['your-category-id']
    };
    
    const newEvent = await api.createEvent(eventData);
    console.log('✅ Event created:', newEvent.data.title);
    
  } catch (error) {
    console.error('❌ API test failed:', error.message);
  }
}

testAPI();
```

### 5. Python

```python
import requests
import json
from typing import Optional, Dict, Any

class BlancakanAPI:
    def __init__(self, base_url: str = "http://localhost:3000"):
        self.base_url = base_url
        self.token: Optional[str] = None
        self.session = requests.Session()
        self.session.timeout = 10

    def sign_in(self, email: str, password: str) -> Dict[str, Any]:
        """Sign in and store the JWT token"""
        response = self.session.post(
            f"{self.base_url}/auth/sign_in",
            json={"email": email, "password": password}
        )
        response.raise_for_status()
        
        data = response.json()
        self.token = data["data"]["token"]
        self.session.headers.update({"Authorization": f"Bearer {self.token}"})
        
        return data

    def get_categories(self) -> Dict[str, Any]:
        """Get all categories"""
        response = self.session.get(f"{self.base_url}/api/v1/admin/categories")
        response.raise_for_status()
        return response.json()

    def create_category(self, name: str, description: str, parent_id: Optional[str] = None) -> Dict[str, Any]:
        """Create a new category"""
        data = {"name": name, "description": description}
        if parent_id:
            data["parent_id"] = parent_id
            
        response = self.session.post(
            f"{self.base_url}/api/v1/admin/categories",
            json=data
        )
        response.raise_for_status()
        return response.json()

    def upload_image_event(self, event_data: Dict[str, Any], image_path: Optional[str] = None) -> Dict[str, Any]:
        """Create an event with optional image upload"""
        files = {}
        if image_path:
            files['image'] = open(image_path, 'rb')
        
        try:
            response = self.session.post(
                f"{self.base_url}/api/v1/admin/events",
                data=event_data,
                files=files
            )
            response.raise_for_status()
            return response.json()
        finally:
            if files:
                files['image'].close()

# Usage example
def test_api():
    api = BlancakanAPI()
    
    try:
        # Sign in
        signin_result = api.sign_in("test@example.com", "password123")
        print("✅ Signed in successfully")
        
        # Create a category
        category = api.create_category(
            name="Test Category",
            description="This is a test category"
        )
        print(f"✅ Category created: {category['data']['name']}")
        
        # Get all categories
        categories = api.get_categories()
        print(f"✅ Retrieved {len(categories['data'])} categories")
        
        # Create an event
        event_data = {
            'title': 'Python Test Event',
            'description': 'Event created from Python script',
            'start_date': '2024-03-15T09:00:00Z',
            'end_date': '2024-03-15T17:00:00Z',
            'location': 'Python Test Location',
            'event_type_id': 'your-event-type-id',
            'category_ids[]': category['data']['_id']
        }
        
        event = api.upload_image_event(event_data)
        print(f"✅ Event created: {event['data']['title']}")
        
    except requests.exceptions.RequestException as e:
        print(f"❌ API test failed: {e}")

if __name__ == "__main__":
    test_api()
```

## Endpoint Testing Examples

### Authentication Flow

```bash
# 1. Register a new user
curl -X POST http://localhost:3000/auth \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "securepassword",
    "password_confirmation": "securepassword"
  }'

# 2. Sign in
curl -X POST http://localhost:3000/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "securepassword"
  }'

# 3. Use the token from step 2 for authenticated requests
export TOKEN="your-jwt-token-here"

# 4. Test authenticated endpoint
curl -X GET http://localhost:3000/api/v1/admin/categories \
  -H "Authorization: Bearer $TOKEN"

# 5. Sign out
curl -X DELETE http://localhost:3000/auth/sign_out \
  -H "Authorization: Bearer $TOKEN"
```

### CRUD Operations

#### Categories

```bash
# Create category
curl -X POST http://localhost:3000/api/v1/admin/categories \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Technology",
    "description": "Technology related events"
  }'

# Get all categories
curl -X GET http://localhost:3000/api/v1/admin/categories \
  -H "Authorization: Bearer $TOKEN"

# Get specific category
curl -X GET http://localhost:3000/api/v1/admin/categories/507f1f77bcf86cd799439011 \
  -H "Authorization: Bearer $TOKEN"

# Update category
curl -X PUT http://localhost:3000/api/v1/admin/categories/507f1f77bcf86cd799439011 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Advanced Technology",
    "description": "Advanced technology related events"
  }'

# Delete category
curl -X DELETE http://localhost:3000/api/v1/admin/categories/507f1f77bcf86cd799439011 \
  -H "Authorization: Bearer $TOKEN"
```

#### Events with File Upload

```bash
# Create event with image
curl -X POST http://localhost:3000/api/v1/admin/events \
  -H "Authorization: Bearer $TOKEN" \
  -F "title=Tech Conference 2024" \
  -F "description=Annual technology conference" \
  -F "start_date=2024-03-15T09:00:00Z" \
  -F "end_date=2024-03-17T18:00:00Z" \
  -F "location=Convention Center" \
  -F "event_type_id=507f1f77bcf86cd799439013" \
  -F "category_ids[]=507f1f77bcf86cd799439014" \
  -F "image=@/path/to/event-image.jpg"
```

### Pagination Testing

```bash
# Test pagination
curl -X GET "http://localhost:3000/api/v1/admin/events?page=1&per_page=5" \
  -H "Authorization: Bearer $TOKEN"

# Test with search
curl -X GET "http://localhost:3000/api/v1/admin/events?search=conference&page=1" \
  -H "Authorization: Bearer $TOKEN"

# Test filtering
curl -X GET "http://localhost:3000/api/v1/admin/events?status=published&category_id=507f1f77bcf86cd799439014" \
  -H "Authorization: Bearer $TOKEN"
```

## Error Handling

### Common Error Scenarios

#### 401 Unauthorized
```bash
# Missing or invalid token
curl -X GET http://localhost:3000/api/v1/admin/categories
# Response: {"status": "error", "message": "Unauthorized"}
```

#### 422 Validation Error
```bash
# Invalid data
curl -X POST http://localhost:3000/api/v1/admin/categories \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "",
    "description": ""
  }'
# Response: validation errors with field details
```

#### 404 Not Found
```bash
# Non-existent resource
curl -X GET http://localhost:3000/api/v1/admin/categories/invalid-id \
  -H "Authorization: Bearer $TOKEN"
# Response: {"status": "error", "message": "Category not found"}
```

### Error Response Format

All error responses follow this structure:

```json
{
  "status": "error",
  "message": "Human-readable error message",
  "errors": [
    {
      "field": "email",
      "code": "blank",
      "message": "can't be blank"
    }
  ]
}
```

## Performance Testing

### Load Testing with Apache Bench

```bash
# Install Apache Bench (ab)
sudo apt-get install apache2-utils  # Ubuntu/Debian
brew install httpd                   # macOS

# Test endpoint performance
ab -n 1000 -c 10 -H "Authorization: Bearer $TOKEN" \
   http://localhost:3000/api/v1/admin/categories

# Test with POST data
ab -n 100 -c 5 -p category_data.json -T application/json \
   -H "Authorization: Bearer $TOKEN" \
   http://localhost:3000/api/v1/admin/categories
```

### Load Testing with wrk

```bash
# Install wrk
git clone https://github.com/wg/wrk.git
cd wrk && make

# Basic load test
./wrk -t12 -c400 -d30s --header "Authorization: Bearer $TOKEN" \
      http://localhost:3000/api/v1/admin/categories

# With custom script
./wrk -t12 -c400 -d30s -s auth_script.lua http://localhost:3000/
```

## Automated Testing

### Test Script Template

```bash
#!/bin/bash

# API Test Suite
set -e

BASE_URL="http://localhost:3000"
EMAIL="test@example.com"
PASSWORD="password123"

echo "🚀 Starting API Test Suite"

# 1. Sign in and get token
echo "📝 Authenticating..."
RESPONSE=$(curl -s -X POST "$BASE_URL/auth/sign_in" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

TOKEN=$(echo $RESPONSE | jq -r '.data.token')

if [ "$TOKEN" = "null" ]; then
  echo "❌ Authentication failed"
  exit 1
fi

echo "✅ Authentication successful"

# 2. Test categories endpoint
echo "📂 Testing categories..."
CATEGORIES_RESPONSE=$(curl -s -X GET "$BASE_URL/api/v1/admin/categories" \
  -H "Authorization: Bearer $TOKEN")

CATEGORIES_STATUS=$(echo $CATEGORIES_RESPONSE | jq -r '.status')

if [ "$CATEGORIES_STATUS" = "success" ]; then
  echo "✅ Categories endpoint working"
else
  echo "❌ Categories endpoint failed"
  exit 1
fi

# 3. Create a test category
echo "➕ Creating test category..."
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/admin/categories" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Category","description":"Test Description"}')

CREATE_STATUS=$(echo $CREATE_RESPONSE | jq -r '.status')

if [ "$CREATE_STATUS" = "success" ]; then
  CATEGORY_ID=$(echo $CREATE_RESPONSE | jq -r '.data._id')
  echo "✅ Category created with ID: $CATEGORY_ID"
else
  echo "❌ Category creation failed"
  exit 1
fi

# 4. Clean up - delete test category
echo "🧹 Cleaning up..."
curl -s -X DELETE "$BASE_URL/api/v1/admin/categories/$CATEGORY_ID" \
  -H "Authorization: Bearer $TOKEN" > /dev/null

echo "✅ Test suite completed successfully"
```

### Continuous Integration

#### GitHub Actions Example

```yaml
name: API Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mongodb:
        image: mongo:4.4
        ports:
          - 27017:27017
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: 3.1
        bundler-cache: true
    
    - name: Setup test database
      run: |
        bundle exec rails db:create RAILS_ENV=test
        bundle exec rails db:seed RAILS_ENV=test
    
    - name: Start Rails server
      run: |
        bundle exec rails server -e test -d
        sleep 10
    
    - name: Run API tests
      run: |
        chmod +x ./scripts/api_test.sh
        ./scripts/api_test.sh
```

This comprehensive testing guide provides you with all the tools and examples needed to thoroughly test your Blancakan API across different scenarios and environments.
