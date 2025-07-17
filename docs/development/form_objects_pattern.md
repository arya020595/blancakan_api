# Form Objects and Service Layer Pattern

## Overview

This document explains the Form Objects and Service Layer pattern implementation in our Rails application, which follows research-backed best practices for clean architecture.

## Architecture Pattern

```
Controller -> Form Object -> Service Layer -> Model
    ↓            ↓             ↓             ↓
HTTP Layer   Validation   Business Logic   Data Layer
```

## Components

### 1. Form Objects (`app/forms/`)

**Purpose**: Handle input validation and data transformation

**Responsibilities**:

- Input validation using Dry-Validation contracts
- Data sanitization and type coercion
- Converting controller params to clean attributes
- Providing Rails-compatible validation interface

**Example**:

```ruby
# app/forms/v1/event/event_form.rb
class EventForm < ApplicationForm
  attribute :title, :string
  attribute :start_date, :datetime

  def valid?
    @validation_result = @contract.call(sanitized_attributes)
    @validation_result.success?
  end

  def sanitized_attributes
    {
      title: strip_string(title),
      start_date: parse_datetime(start_date)
    }.compact
  end
end
```

### 2. Contracts (`app/contracts/`)

**Purpose**: Define validation rules using Dry-Validation

**Responsibilities**:

- Schema validation (types, required fields)
- Business rule validation
- Cross-field validation
- Database existence checks

**Example**:

```ruby
# app/contracts/v1/event/event_contract.rb
class EventContract < Dry::Validation::Contract
  params do
    required(:title).filled(:string)
    required(:start_date).filled(:date_time)
  end

  rule(:title) do
    key.failure('must be at least 3 characters') if value.length < 3
  end
end
```

### 3. Service Layer (`app/services/`)

**Purpose**: Handle business logic and coordination

**Responsibilities**:

- Pure business logic (no validation)
- Model coordination
- External service integration
- Background job triggering

**Example**:

```ruby
# app/services/v1/event_service.rb
class EventService
  def create(validated_attributes)
    event = Event.new(validated_attributes)

    if event.save
      trigger_notifications(event)
      Success(event)
    else
      Failure(event.errors.full_messages)
    end
  end
end
```

### 4. Controllers (`app/controllers/`)

**Purpose**: HTTP orchestration

**Responsibilities**:

- Parameter extraction
- Form validation coordination
- Service method calling
- Response formatting

**Example**:

```ruby
def create
  form = V1::Event::EventForm.new(event_params)

  if form.valid?
    result = @event_service.create(form.attributes)
    format_response(result: result, resource: 'events', action: :create)
  else
    result = Failure(form.errors.full_messages)
    format_response(result: result, resource: 'events', action: :create)
  end
end
```

## Benefits

### ✅ **Separation of Concerns**

- Each layer has a single responsibility
- Easy to test each component in isolation
- Changes in one layer don't affect others

### ✅ **Better Testing**

```ruby
# Test validation separately
RSpec.describe EventForm do
  it 'validates required fields' do
    form = EventForm.new(name: '')
    expect(form).not_to be_valid
  end
end

# Test business logic separately
RSpec.describe EventService do
  it 'creates event and triggers notifications' do
    result = service.create(valid_attributes)
    expect(result).to be_success
  end
end
```

### ✅ **Reusability**

- Same form can be used for different actions
- Same service can be called from different controllers
- Same contract can be used in different contexts

### ✅ **Type Safety**

- ActiveModel::Attributes provides type coercion
- Dry-Validation ensures data integrity
- Clear data transformation pipeline

## Research Backing

This pattern is supported by:

1. **"Clean Architecture" by Robert C. Martin**

   - Input Boundaries (Form Objects)
   - Use Cases (Services)
   - Entities (Models)

2. **"Domain-Driven Design" by Eric Evans**

   - Application Services
   - Value Objects
   - Repository Pattern

3. **Industry Best Practices**
   - Thoughtbot recommendations
   - Dry-rb community patterns
   - Rails community evolution

## Usage Guidelines

### ✅ **Do**

- Keep validation in form objects
- Keep business logic in services
- Use type-safe attributes
- Sanitize input data
- Test each layer separately

### ❌ **Don't**

- Put validation in services
- Put business logic in form objects
- Skip the form layer
- Mix HTTP concerns with business logic

## File Structure

```
app/
├── forms/
│   ├── application_form.rb
│   └── v1/
│       └── event/
│           └── event_form.rb
├── contracts/
│   └── v1/
│       └── event/
│           └── event_contract.rb
├── services/
│   └── v1/
│       └── event_service.rb
└── controllers/
    └── api/
        └── v1/
            └── admin/
                └── events_controller.rb
```

## Testing Strategy

### Form Objects

```ruby
# Test validation rules
# Test data sanitization
# Test error handling
```

### Contracts

```ruby
# Test business rules
# Test cross-field validation
# Test edge cases
```

### Services

```ruby
# Test business logic
# Test success/failure paths
# Test side effects (notifications, etc.)
```

### Controllers

```ruby
# Test request/response flow
# Test error handling
# Test parameter processing
```

This pattern provides a scalable, maintainable, and testable architecture for complex Rails applications.
