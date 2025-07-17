# Architecture Overview

## Clean Architecture Principles

The Blancakan API follows Clean Architecture principles, ensuring separation of concerns, testability, and maintainability. The architecture is organized in layers with clear dependencies flowing inward.

## Architecture Layers

```
┌─────────────────────────────────────────────┐
│                Controllers                   │ ← Interface Layer
├─────────────────────────────────────────────┤
│            Use Cases/Interactors            │ ← Application Layer
├─────────────────────────────────────────────┤
│  Services | Repositories | Domain Objects   │ ← Domain Layer
├─────────────────────────────────────────────┤
│        Database | External Services         │ ← Infrastructure Layer
└─────────────────────────────────────────────┘
```

### 1. Interface Layer (Controllers)

- **Responsibility**: Handle HTTP requests/responses
- **Components**: Controllers, Serializers, Form Objects
- **Dependencies**: Application Layer

### 2. Application Layer (Use Cases)

- **Responsibility**: Orchestrate business logic
- **Components**: Interactors, Services, Query Objects
- **Dependencies**: Domain Layer

### 3. Domain Layer (Business Logic)

- **Responsibility**: Core business rules and entities
- **Components**: Models, Value Objects, Policies
- **Dependencies**: None (pure domain logic)

### 4. Infrastructure Layer (External Concerns)

- **Responsibility**: Database, external APIs, frameworks
- **Components**: Repositories, Adapters, Jobs
- **Dependencies**: All layers can depend on this

## Key Design Principles

### SOLID Principles

#### Single Responsibility Principle (SRP)

Each class has one reason to change:

- **Form Objects**: Input validation only
- **Query Objects**: Database queries only
- **Value Objects**: Data representation only
- **Services**: Single business operation

#### Open/Closed Principle (OCP)

Open for extension, closed for modification:

- **Strategy Pattern**: Different email providers
- **Adapter Pattern**: Swappable external services
- **Policy Pattern**: Extensible authorization

#### Liskov Substitution Principle (LSP)

Subtypes must be substitutable:

- **Repository Interfaces**: Any implementation works
- **Service Interfaces**: Consistent behavior

#### Interface Segregation Principle (ISP)

Clients shouldn't depend on unused interfaces:

- **Small, focused interfaces**
- **Role-specific serializers**
- **Targeted policies**

#### Dependency Inversion Principle (DIP)

Depend on abstractions, not concretions:

- **Repository pattern**
- **Service injection**
- **Adapter interfaces**

## Data Flow

### Request Lifecycle

```
HTTP Request
    ↓
Controller (Interface Layer)
    ↓
Form Object (Validation)
    ↓
Interactor/Service (Application Layer)
    ↓
Repository/Query Object (Domain Layer)
    ↓
Model/Database (Infrastructure Layer)
    ↓
Serializer (Interface Layer)
    ↓
HTTP Response
```

### Example: User Registration Flow

```ruby
# 1. Controller receives request
def register
  # 2. Form object validates input
  form = Auth::RegistrationForm.new(register_params)

  # 3. Interactor orchestrates business logic
  result = Auth::RegisterUser.call(form.attributes)

  # 4. Format response
  format_response(result: result, ...)
end

# Interactor coordinates the operation
class Auth::RegisterUser
  def call(params)
    # 5. Repository handles data persistence
    user = user_repository.create(params)

    # 6. Service handles side effects
    email_service.send_welcome_email(user)

    Success(user)
  end
end
```

## Architectural Patterns

### Repository Pattern

Abstracts data access layer:

```ruby
# Interface
class UserRepositoryInterface
  def find_by_email(email)
    raise NotImplementedError
  end
end

# Implementation
class UserRepository < UserRepositoryInterface
  def find_by_email(email)
    User.find_by(email: email)
  end
end
```

### Service Object Pattern

Encapsulates business operations:

```ruby
class Users::CreateUserService
  def initialize(user_repository: UserRepository.new)
    @user_repository = user_repository
  end

  def call(params)
    # Business logic here
    user_repository.create(params)
  end
end
```

### Value Object Pattern

Immutable data objects:

```ruby
class Email
  attr_reader :value

  def initialize(value)
    @value = value.downcase.strip
    validate!
    freeze
  end

  def domain
    value.split('@').last
  end
end
```

### Form Object Pattern

Input validation and transformation:

```ruby
class RegistrationForm
  include ActiveModel::Model

  validates :email, presence: true, format: { with: EMAIL_REGEX }
  validates :password, length: { minimum: 8 }

  def to_user_params
    { email: email.downcase, password: password }
  end
end
```

### Query Object Pattern

Database query abstraction:

```ruby
class Users::ActiveUsersQuery
  def initialize(relation = User.all)
    @relation = relation
  end

  def call
    relation.where(active: true)
            .where(:deleted_at.exists => false)
  end
end
```

## Dependency Injection

### Manual Injection

```ruby
class UsersController
  def initialize
    @user_service = UserService.new(
      repository: UserRepository.new,
      email_service: EmailService.new
    )
  end
end
```

### Container-Based Injection

```ruby
# config/initializers/container.rb
Container.register('user_repository') { UserRepository.new }
Container.register('email_service') { EmailService.new }
Container.register('user_service') do
  UserService.new(
    repository: Container.resolve('user_repository'),
    email_service: Container.resolve('email_service')
  )
end
```

## Error Handling

### Result Pattern

```ruby
class SomeService
  include Dry::Monads[:result]

  def call(params)
    return Failure(validation_errors) unless valid?(params)

    user = create_user(params)
    Success(user)
  rescue StandardError => e
    Failure(e.message)
  end
end
```

### Global Error Handling

```ruby
class ApplicationController
  rescue_from StandardError, with: :handle_standard_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  private

  def handle_standard_error(error)
    render json: { error: error.message }, status: :internal_server_error
  end
end
```

## Testing Strategy

### Unit Tests

- **Models**: Validation, associations, methods
- **Value Objects**: Immutability, behavior
- **Services**: Business logic, edge cases
- **Form Objects**: Validation rules

### Integration Tests

- **Controllers**: Request/response flow
- **Services**: Multi-object interactions
- **Repositories**: Database operations

### System Tests

- **API Endpoints**: End-to-end functionality
- **Authentication**: Token flow
- **Authorization**: Permission checks

## Performance Considerations

### Database Optimization

- **Indexing**: Strategic MongoDB indexes
- **Query Objects**: Optimized queries
- **Pagination**: Limit result sets

### Caching Strategy

- **Service-level caching**: Expensive operations
- **Serializer caching**: Response formatting
- **Repository caching**: Frequently accessed data

### Background Processing

- **Sidekiq Jobs**: Async operations
- **Email sending**: Non-blocking
- **Data processing**: Heavy operations

## Monitoring & Observability

### Logging

- **Structured logging**: JSON format
- **Request tracking**: UUID correlation
- **Service boundaries**: Entry/exit points

### Metrics

- **Response times**: Performance monitoring
- **Error rates**: Reliability tracking
- **Business metrics**: Feature usage

### Health Checks

- **Database connectivity**
- **External service status**
- **Background job health**

## Security Architecture

### Authentication

- **JWT tokens**: Stateless authentication
- **Token expiration**: Configurable lifetime
- **Secure headers**: CORS, CSP

### Authorization

- **Role-based access**: Granular permissions
- **Policy objects**: Centralized rules
- **Resource scoping**: User-owned data

### Data Protection

- **Input validation**: Form objects
- **SQL injection**: Parameterized queries
- **XSS protection**: Serializer escaping

This architecture provides a solid foundation for building scalable, maintainable Rails APIs while following industry best practices and clean code principles.
