# SOLID Principles Implementation

This document explains how the Blancakan API implements each of the SOLID principles with concrete examples from the codebase.

## Single Responsibility Principle (SRP)

_"A class should have only one reason to change."_

### Implementation Examples

#### Form Objects - Input Validation Only

```ruby
# app/form_objects/auth/registration_form.rb
class Auth::RegistrationForm < ApplicationForm
  # SINGLE RESPONSIBILITY: Input validation and transformation

  validates :name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, format: { with: EMAIL_REGEX }
  validates :password, presence: true, length: { minimum: 8 }

  def to_user_params
    {
      name: name.strip,
      email: email.downcase.strip,
      password: password
    }
  end

  # This class ONLY handles:
  # 1. Input validation
  # 2. Data transformation
  # It does NOT handle:
  # - Database operations
  # - Business logic
  # - Email sending
end
```

#### Query Objects - Database Queries Only

```ruby
# app/query_objects/users/active_users_query.rb
class Users::ActiveUsersQuery < ApplicationQuery
  # SINGLE RESPONSIBILITY: Construct specific database queries

  def call
    relation.where(active: true)
            .where(:deleted_at.exists => false)
            .order_by(created_at: :desc)
  end

  # This class ONLY handles:
  # 1. Building database queries
  # It does NOT handle:
  # - Validation
  # - Business logic
  # - Response formatting
end
```

#### Value Objects - Data Representation Only

```ruby
# app/value_objects/email.rb
class Email
  # SINGLE RESPONSIBILITY: Represent and validate email data

  def initialize(value)
    @value = value.to_s.downcase.strip
    validate!
    freeze
  end

  def domain
    @value.split('@').last
  end

  def local_part
    @value.split('@').first
  end

  # This class ONLY handles:
  # 1. Email representation
  # 2. Email validation
  # 3. Email parsing
  # It does NOT handle:
  # - Database operations
  # - HTTP requests
  # - Business logic
end
```

#### Service Objects - Single Business Operation

```ruby
# app/services/auth/authentication_service.rb
class Auth::AuthenticationService
  # SINGLE RESPONSIBILITY: User authentication logic

  def authenticate(email, password)
    user = user_repository.find_by_email(Email.new(email))
    return Failure('User not found') unless user
    return Failure('Invalid password') unless user.authenticate(password)

    Success(user)
  end

  # This class ONLY handles:
  # 1. User authentication
  # It does NOT handle:
  # - Token generation
  # - Response formatting
  # - User registration
end
```

## Open/Closed Principle (OCP)

_"Software entities should be open for extension, closed for modification."_

### Implementation Examples

#### Email Adapter Pattern

```ruby
# app/adapters/email/email_adapter_interface.rb
module Email
  class EmailAdapterInterface
    def send_email(to:, subject:, body:)
      raise NotImplementedError
    end
  end
end

# app/adapters/email/sendgrid_adapter.rb
module Email
  class SendgridAdapter < EmailAdapterInterface
    def send_email(to:, subject:, body:)
      # Sendgrid implementation
    end
  end
end

# app/adapters/email/mailgun_adapter.rb
module Email
  class MailgunAdapter < EmailAdapterInterface
    def send_email(to:, subject:, body:)
      # Mailgun implementation
    end
  end
end

# Adding new email providers doesn't require modifying existing code
# Just create a new adapter implementing the interface
```

#### Serializer Extension

```ruby
# app/serializers/application_serializer.rb
class ApplicationSerializer < ActiveModel::Serializer
  # Base functionality - CLOSED for modification
end

# app/serializers/user_serializer.rb
class UserSerializer < ApplicationSerializer
  # OPEN for extension - adds user-specific fields
  attributes :id, :name, :email, :authorization

  def authorization
    token = instance_options[:token]
    "Bearer #{token}" if token.present?
  end
end

# app/serializers/admin/detailed_user_serializer.rb
class Admin::DetailedUserSerializer < UserSerializer
  # OPEN for extension - adds admin-specific fields
  attributes :role, :last_login, :permissions
end
```

#### Policy Extension

```ruby
# app/policies/application_policy.rb
class ApplicationPolicy
  # Base authorization rules - CLOSED for modification

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end
end

# app/policies/event_policy.rb
class EventPolicy < ApplicationPolicy
  # OPEN for extension - adds event-specific rules

  def show?
    record.public? || user.present?
  end

  def update?
    user&.admin? || (user&.organizer? && record.user == user)
  end
end

# Adding new resources doesn't require modifying ApplicationPolicy
```

## Liskov Substitution Principle (LSP)

_"Objects of a superclass should be replaceable with objects of a subclass without altering the correctness of the program."_

### Implementation Examples

#### Repository Interfaces

```ruby
# app/repositories/contracts/user_repository_interface.rb
module Contracts
  class UserRepositoryInterface
    def find_by_email(email)
      raise NotImplementedError
    end

    def create(attributes)
      raise NotImplementedError
    end

    def update(user, attributes)
      raise NotImplementedError
    end
  end
end

# app/repositories/user_repository.rb
class UserRepository < Contracts::UserRepositoryInterface
  def find_by_email(email)
    User.find_by(email: email.to_s)
  end

  def create(attributes)
    User.create!(attributes)
  end

  def update(user, attributes)
    user.update!(attributes)
    user
  end
end

# app/repositories/cached_user_repository.rb
class CachedUserRepository < Contracts::UserRepositoryInterface
  def initialize(cache_store = Rails.cache)
    @cache_store = cache_store
  end

  def find_by_email(email)
    cache_store.fetch("user:#{email}", expires_in: 1.hour) do
      User.find_by(email: email.to_s)
    end
  end

  def create(attributes)
    user = User.create!(attributes)
    cache_store.delete("user:#{user.email}")
    user
  end

  def update(user, attributes)
    user.update!(attributes)
    cache_store.delete("user:#{user.email}")
    user
  end
end

# Both implementations can be used interchangeably:
def some_service(user_repository = UserRepository.new)
  # This works with any repository implementation
  user_repository.find_by_email('test@example.com')
end

some_service(UserRepository.new)
some_service(CachedUserRepository.new)
```

#### Adapter Substitution

```ruby
# Any email adapter can replace another without changing client code
class EmailService
  def initialize(adapter = Email::SendgridAdapter.new)
    @adapter = adapter
  end

  def send_welcome_email(user)
    adapter.send_email(
      to: user.email,
      subject: 'Welcome!',
      body: welcome_template(user)
    )
  end
end

# These are all valid and interchangeable:
EmailService.new(Email::SendgridAdapter.new)
EmailService.new(Email::MailgunAdapter.new)
EmailService.new(Email::SmtpAdapter.new)
```

## Interface Segregation Principle (ISP)

_"Clients should not be forced to depend upon interfaces that they do not use."_

### Implementation Examples

#### Specific Repository Interfaces

```ruby
# Instead of one large interface:
# BAD: Fat interface
class RepositoryInterface
  def find(id); end
  def find_all; end
  def create(attrs); end
  def update(id, attrs); end
  def delete(id); end
  def search(query); end
  def export_csv; end
  def import_csv(file); end
end

# GOOD: Segregated interfaces
module Contracts
  class ReadableRepositoryInterface
    def find(id); end
    def find_all; end
  end

  class WritableRepositoryInterface
    def create(attrs); end
    def update(id, attrs); end
    def delete(id); end
  end

  class SearchableRepositoryInterface
    def search(query); end
  end

  class ExportableRepositoryInterface
    def export_csv; end
    def import_csv(file); end
  end
end

# Clients only depend on what they need:
class ReadOnlyService
  def initialize(repository)
    # Only depends on readable interface
    @repository = repository
  end
end

class SearchService
  def initialize(repository)
    # Only depends on searchable interface
    @repository = repository
  end
end
```

#### Role-Specific Serializers

```ruby
# Instead of one large serializer:
# BAD: Fat serializer
class UserSerializer
  attributes :id, :name, :email, :password_hash, :admin_notes,
             :internal_id, :permissions, :audit_log
end

# GOOD: Role-specific serializers
class PublicUserSerializer < ApplicationSerializer
  attributes :id, :name
end

class AuthenticatedUserSerializer < ApplicationSerializer
  attributes :id, :name, :email
end

class AdminUserSerializer < ApplicationSerializer
  attributes :id, :name, :email, :role, :permissions, :last_login
end

class InternalUserSerializer < ApplicationSerializer
  attributes :id, :name, :email, :internal_id, :admin_notes, :audit_log
end
```

#### Targeted Policies

```ruby
# Instead of one large policy:
# BAD: Fat policy
class UserPolicy
  def view_profile?; end
  def edit_profile?; end
  def view_admin_panel?; end
  def manage_users?; end
  def view_analytics?; end
  def export_data?; end
end

# GOOD: Segregated policies
class UserProfilePolicy
  def view?; end
  def edit?; end
end

class AdminPanelPolicy
  def access?; end
  def manage_users?; end
end

class AnalyticsPolicy
  def view?; end
  def export?; end
end
```

## Dependency Inversion Principle (DIP)

_"Depend upon abstractions, not concretions."_

### Implementation Examples

#### Service Dependencies

```ruby
# BAD: Depending on concrete classes
class UserRegistrationService
  def call(params)
    # Direct dependency on concrete classes
    user = User.create!(params)
    EmailService.new.send_welcome_email(user)
    SlackNotifier.new.notify_admin(user)
  end
end

# GOOD: Depending on abstractions
class UserRegistrationService
  def initialize(
    user_repository: UserRepository.new,
    email_service: EmailService.new,
    notification_service: NotificationService.new
  )
    @user_repository = user_repository
    @email_service = email_service
    @notification_service = notification_service
  end

  def call(params)
    user = user_repository.create(params)
    email_service.send_welcome_email(user)
    notification_service.notify_admin(user)
  end
end
```

#### Controller Dependencies

```ruby
# BAD: Controllers depending on concrete services
class UsersController < ApplicationController
  def create
    # Direct dependency on concrete service
    service = UserCreationService.new
    result = service.call(user_params)
    # ...
  end
end

# GOOD: Controllers depending on abstractions
class UsersController < ApplicationController
  def initialize
    super
    @user_service = Container.resolve('user_service')
  end

  def create
    result = @user_service.create(user_params)
    format_response(result: result, ...)
  end
end

# Container configuration
Container.register('user_repository') { UserRepository.new }
Container.register('email_service') { EmailService.new }
Container.register('user_service') do
  UserCreationService.new(
    user_repository: Container.resolve('user_repository'),
    email_service: Container.resolve('email_service')
  )
end
```

#### Adapter Pattern for External Services

```ruby
# BAD: Direct dependency on external service
class NotificationService
  def send_notification(message)
    # Direct dependency on Slack
    slack_client = Slack::Web::Client.new
    slack_client.chat_postMessage(
      channel: '#notifications',
      text: message
    )
  end
end

# GOOD: Abstraction with adapters
module Notifications
  class NotificationAdapterInterface
    def send(message)
      raise NotImplementedError
    end
  end
end

class SlackAdapter < Notifications::NotificationAdapterInterface
  def send(message)
    slack_client.chat_postMessage(
      channel: '#notifications',
      text: message
    )
  end
end

class EmailAdapter < Notifications::NotificationAdapterInterface
  def send(message)
    mailer.notification_email(message).deliver_now
  end
end

class NotificationService
  def initialize(adapter = SlackAdapter.new)
    @adapter = adapter
  end

  def send_notification(message)
    adapter.send(message)
  end
end
```

## Benefits of SOLID Implementation

### 1. **Maintainability**

- Easy to locate and fix bugs
- Clear separation of concerns
- Minimal impact when making changes

### 2. **Testability**

- Easy to mock dependencies
- Isolated unit tests
- Clear test boundaries

### 3. **Extensibility**

- Add new features without modifying existing code
- Plugin architecture for adapters
- Easy to add new business rules

### 4. **Reusability**

- Components can be reused across different contexts
- Clear interfaces enable composition
- Dependency injection enables flexibility

### 5. **Team Collaboration**

- Clear boundaries reduce merge conflicts
- Consistent patterns across the codebase
- New team members can understand architecture quickly

This SOLID implementation ensures that the Blancakan API remains maintainable, testable, and extensible as it grows in complexity and features.
