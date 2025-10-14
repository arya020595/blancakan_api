# Blancakan API Documentation

Welcome to the Blancakan API documentation. This is a clean, scalable Rails API following SOLID principles and clean architecture patterns.

## 📚 Documentation Structure

```
docs/
├── README.md                    # This file - Overview and navigation
├── api/
│   ├── authentication.md       # Authentication & Authorization
│   ├── endpoints.md            # API Endpoints Reference
│   ├── response_format.md      # Standard Response Formats
│   └── examples.md             # Request/Response Examples
├── architecture/
│   ├── overview.md             # Architecture Overview
│   ├── solid_principles.md     # SOLID Principles Implementation
│   ├── folder_structure.md     # Folder Structure Guide
│   ├── design_patterns.md      # Design Patterns Used
│   └── data_flow.md           # Data Flow & Request Lifecycle
├── authorization/              # **NEW: Authorization System**
│   ├── README.md              # Complete authorization guide
│   ├── QUICK_REFERENCE.md     # Quick reference and cheat sheet
│   └── COMPLETE_EXAMPLE.md    # Step-by-step implementation example
├── development/
│   ├── setup.md               # Development Setup
│   ├── testing.md             # Testing Guide
│   ├── coding_standards.md    # Coding Standards & Best Practices
│   ├── form_objects_pattern.md # Form Objects Pattern Guide
│   └── contributing.md        # Contributing Guidelines
├── deployment/
│   ├── production.md          # Production Deployment
│   ├── environment_variables.md # Environment Configuration
│   └── monitoring.md          # Monitoring & Logging
├── elasticsearch/              # Elasticsearch Integration
│   ├── README.md              # Elasticsearch setup and usage
│   ├── QUICK_REFERENCE.md     # Quick reference guide
│   └── COMPLETE_EXAMPLE.md    # Complete examples
├── mongodb_search/             # MongoDB Search System
│   ├── README.md              # MongoDB search documentation
│   ├── QUICK_REFERENCE.md     # Quick reference guide
│   └── COMPLETE_EXAMPLE.md    # Complete examples
└── helper/
    └── helper_logger.md       # Logging helper documentation
```

## 🚀 Quick Start

1. **API Documentation**: Start with [API Endpoints](api/endpoints.md)
2. **Authentication**: Learn about [Authentication & Authorization](api/authentication.md)
3. **Authorization**: Understand [Role-Based Access Control](authorization/README.md)
4. **Architecture**: Understand the [Architecture Overview](architecture/overview.md)
5. **Development**: Set up your [Development Environment](development/setup.md)

## 🏗️ Architecture Highlights

- **Clean Architecture**: Separation of concerns with clear layers
- **SOLID Principles**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **Design Patterns**: Value Objects, Form Objects, Query Objects, Repository Pattern, Service Objects
- **Modular Structure**: Domain-driven design with clear boundaries

## 📖 Key Features

- **JWT Authentication**: Secure token-based authentication
- **Role-Based Authorization**: CanCanCan-powered granular permission system ([docs](authorization/README.md))
- **Event Management**: Comprehensive event management system
- **Search Integration**: Elasticsearch-powered search ([docs](elasticsearch/README.md))
- **MongoDB Search**: Native MongoDB text and regex search ([docs](mongodb_search/README.md))
- **File Uploads**: Cloudinary integration for media management
- **Background Jobs**: Sidekiq for asynchronous processing
- **API Documentation**: Swagger/OpenAPI 3.0 specification
- **Form Objects**: Clean validation layer ([docs](development/form_objects_pattern.md))

## 🛠️ Tech Stack

- **Framework**: Ruby on Rails 7.1.5
- **Database**: MongoDB with Mongoid ODM
- **Authentication**: JWT with custom service
- **Search**: Elasticsearch
- **File Storage**: Cloudinary
- **Background Jobs**: Sidekiq with Redis
- **API Documentation**: Swagger/OpenAPI
- **Testing**: RSpec with FactoryBot

## 📝 API Version

Current API version: **v1**

Base URL: `http://localhost:3000/api/v1`

## 🔐 Authentication

All API endpoints (except authentication) require a valid JWT token:

```
Authorization: Bearer <your-jwt-token>
```

## 📋 Available Resources

- **Users**: User management and profiles
- **Events**: Event creation and management
- **Categories**: Event categorization
- **Roles & Permissions**: Authorization system
- **Authentication**: Sign in, sign up, sign out

## 🤝 Contributing

Please read our [Contributing Guidelines](development/contributing.md) before submitting pull requests.

## 📞 Support

For questions or support, please contact the development team or create an issue in the repository.
