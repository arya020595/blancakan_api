# Blancakan API - AI Coding Agent Instructions

## Architecture Overview

This is a **Rails 7.1 API-only application** using **MongoDB (Mongoid ODM)** with clean architecture and SOLID principles. No ActiveRecord - all models use Mongoid.

### Key Architectural Decisions

- **Service Layer Pattern**: Business logic lives in `app/services/v1/` using dry-monads for result objects
- **Form Objects Pattern**: Input validation separated from models in `app/forms/v1/` using dry-validation contracts
- **Dependency Injection**: Services registered in `config/initializers/container.rb` using dry-container
- **Multi-Search Strategy**: Elasticsearch for complex searches, MongoDB native search for simpler needs (documented in `docs/elasticsearch/` and `docs/mongodb_search/`)
- **Authorization**: CanCanCan with dynamic permission conditions supporting placeholders like `"user.organizer.id"` (see `app/models/ability.rb`)

## Critical Workflows

### Running the Application
```bash
# Setup
bundle install
rails db:seed  # Seeds MongoDB, not SQL

# Development server
rails s

# Run tests
bundle exec rspec

# Background jobs
bundle exec sidekiq

# Elasticsearch indexing
rails runner "Event.import force: true"
```

### Datetime Handling Pattern
Events store **both local and UTC** datetimes:
- Frontend sends `starts_at_local` + `timezone` (IANA format like 'America/Los_Angeles')
- Model callback `sync_utc_datetimes` auto-generates `starts_at_utc` and `ends_at_utc`
- Query/sort on UTC fields; display using local + timezone
- See `app/models/concerns/events/date_time_validations.rb`

## Project-Specific Conventions

### Service Object Pattern
Services return **dry-monad** result objects (Success/Failure), never raise exceptions for business logic:

```ruby
# app/services/v1/event_service.rb
def create(params)
  form = V1::Event::EventForm.new(params)
  return Failure(form.errors.full_messages) unless form.valid?
  
  event = Event.new(form.sanitized_attributes)
  event.save ? Success(event) : Failure(event.errors.full_messages)
end
```

Controllers use `ServiceResponseFormatter` mixin:
```ruby
result = @event_service.create(event_params)
format_response(result: result, resource: 'events', action: :create)
```

### Form Objects Pattern
All input validation uses form objects + dry-validation contracts (NOT model validations):

```ruby
# app/forms/v1/event/event_form.rb inherits from ApplicationForm
# app/contracts/v1/event/event_contract.rb defines validation rules

form = V1::Event::EventForm.new(params)
form.valid? # Runs contract validation
form.sanitized_attributes # Clean data ready for model
```

Model validations are **guardrails only** - forms are primary validation layer.

### Controller Authorization Pattern
All admin controllers inherit from `Api::V1::Admin::BaseController` which includes:
- `load_and_authorize_resource` (CanCanCan) - auto-loads `@event`, `@events`, etc.
- `Authenticatable` concern - sets `@current_user` from JWT
- `ServiceResponseFormatter` - standardizes responses

No manual `current_user` checks - authorization happens via `app/models/ability.rb`.

### MongoDB Indexing Strategy
Critical indexes defined in models (see `app/models/event.rb`):
```ruby
index({ slug: 1 }, { unique: true, sparse: true, background: true })
index({ status: 1, starts_at_utc: 1 }, { background: true })
# Always use background: true for production safety
```

## Search Implementation Patterns

### Elasticsearch Models
Include `Elasticsearch::EventSearchable` concern and define:
```ruby
def self.elasticsearch_searchable_fields
  %w[title description]
end

def self.elasticsearch_sortable_fields
  %w[title created_at starts_at_utc]
end
```
Use `Elasticsearch::SearchFacade` in services for search operations.

### MongoDB Search Models
Include `MongodbSearch::EventTypeSearchable` for simpler models:
```ruby
def self.mongodb_searchable_fields
  %w[name description]
end
```
Uses regex search, adequate for smaller datasets.

## Integration Points

### Authentication Flow
1. POST `/auth/sign_in` → JWT token via `JwtService.encode`
2. All API requests require `Authorization: Bearer <token>` header
3. `Authenticatable` concern decodes token → sets `@current_user`
4. Tokens expire per `JWT_EXPIRY_HOURS` env var (default: 24h)

### File Uploads
CarrierWave + Cloudinary integration:
- Mount uploader in model: `mount_uploader :cover_image, ImageUploader`
- Callbacks handle cleanup: `before_update :destroy_previous_image_if_changed`
- Config in `config/initializers/cloudinary.rb` and `carrierwave.rb`

### Background Jobs
Sidekiq for async work:
- Queue adapter set in `config/application.rb`
- Example: `ReindexElasticsearchJob` after model changes
- Redis required (configured via credentials)

## Common Gotchas

1. **No ActiveRecord**: Don't use `rails generate model` - models need `include Mongoid::Document`
2. **Slug Uniqueness**: `mongoid-slug` auto-generates from title, validates uniqueness
3. **BSON::ObjectId**: MongoDB IDs are ObjectIds, not integers - parse with `BSON::ObjectId.from_string(id)`
4. **Authorization Conditions**: Placeholders like `"user.organizer.id"` in permissions get resolved dynamically in `Ability#process_conditions` method
5. **Seeding**: Use `Event.destroy_all` (Mongoid), not `Event.delete_all` (skips callbacks)
6. **Timezone Safety**: Always set `timezone` field, never use `Time.now` without zone context

## Testing Patterns

RSpec with FactoryBot (see `spec/factories/`):
- `database_cleaner-mongoid` handles test cleanup
- Models are in `spec/models/`, requests in `spec/requests/`
- Services in `spec/services/`, forms in `spec/forms/`

## Key Documentation References

- Full architecture: `docs/architecture/overview.md`
- Authorization system: `docs/authorization/README.md` (includes condition placeholder system)
- Elasticsearch: `docs/elasticsearch/README.md` 
- MongoDB search: `docs/mongodb_search/README.md`
- Form objects: `docs/development/form_objects_pattern.md`
- API structure: `docs/README.md`

## Environment Variables

Core vars (see `.env.example`):
- `JWT_EXPIRY_HOURS` - Token expiration (default: 24)
- MongoDB connection in `config/mongoid.yml`
- Elasticsearch/Cloudinary credentials in `config/credentials.yml.enc`
