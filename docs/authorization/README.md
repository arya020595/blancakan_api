# Authorization System Documentation

## Overview

This application uses **CanCanCan** for role-based authorization (RBAC). The authorization system controls what actions users can perform on resources based on their assigned role and permissions.

## Table of Contents

1. [Architecture](#architecture)
2. [Core Components](#core-components)
3. [How It Works](#how-it-works)
4. [Implementation Guide](#implementation-guide)
5. [Usage Examples](#usage-examples)
6. [Testing Authorization](#testing-authorization)
7. [Common Patterns](#common-patterns)
8. [Troubleshooting](#troubleshooting)

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Authorization Flow                      │
└─────────────────────────────────────────────────────────────┘

  User Request
       │
       ▼
  ┌────────────────┐
  │ Authentication │  (JWT Token → Current User)
  └────────┬───────┘
           │
           ▼
  ┌────────────────┐
  │  Authorization │  (CanCanCan checks Ability)
  └────────┬───────┘
           │
           ▼
  ┌────────────────────────────────────────┐
  │          Ability.rb                     │
  │  ┌──────────────────────────────────┐  │
  │  │ 1. Check if user exists          │  │
  │  │ 2. Get user's role               │  │
  │  │ 3. Load role's permissions       │  │
  │  │ 4. Define abilities (can/cannot) │  │
  │  └──────────────────────────────────┘  │
  └────────┬───────────────────────────────┘
           │
           ▼
  ┌────────────────┐
  │   Controller   │  (Executes action if authorized)
  │     Action     │
  └────────────────┘
```

## Core Components

### 1. User Model (`app/models/user.rb`)

The User model includes:
- Association with Role (`belongs_to :role`)
- Default role assignment on creation
- Authentication logic

```ruby
class User
  belongs_to :role, optional: true
  
  before_validation :set_default_role, on: :create
  
  private
  
  def set_default_role
    self.role ||= Role.find_or_create_by(name: 'organizer')
  end
end
```

### 2. Role Model (`app/models/role.rb`)

Defines user roles in the system:
- Has many users
- Has many permissions (dependent destroy)
- Predefined roles: `superadmin`, `admin`, `organizer`, `premium_organizer`

```ruby
class Role
  field :name, type: String
  field :description, type: String
  
  has_many :users
  has_many :permissions, dependent: :destroy
end
```

### 3. Permission Model (`app/models/permission.rb`)

Defines granular permissions for roles:
- **action**: The operation (e.g., `read`, `create`, `update`, `destroy`, `manage`)
- **subject_class**: The model/resource (e.g., `Event`, `User`, `Ticket`)
- **conditions**: Optional hash for conditional permissions

```ruby
class Permission
  field :action, type: String          # "read", "create", "update", "destroy", "manage"
  field :subject_class, type: String   # "Event", "User", "Ticket"
  field :conditions, type: Hash, default: {}  # { user_id: "user.id" }
  
  belongs_to :role
end
```

### 4. Ability Class (`app/models/ability.rb`)

The central authorization logic:

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present? # Guests have no permissions

    role = user.role
    if role.blank?
      cannot :manage, :all # Deny all if no role
      return
    end

    if role.name == 'superadmin'
      can :manage, :all # Full access
      return
    end

    # Grant permissions based on role
    role.permissions.each do |permission|
      action = permission.action.to_sym
      model_class = permission.subject_class.classify.safe_constantize
      next unless model_class

      if permission.conditions.present?
        conditions = permission.conditions.deep_symbolize_keys
        can action, model_class, conditions
      else
        can action, model_class
      end
    end
  end
end
```

### 5. Controllers

Controllers use CanCanCan to enforce authorization:

**Base Admin Controller** (`app/controllers/api/v1/admin/base_controller.rb`):
```ruby
class Api::V1::Admin::BaseController < Api::BaseController
  include Authenticatable  # Sets @current_user
  
  load_and_authorize_resource  # Automatic CanCanCan authorization
end
```

## How It Works

### Authorization Flow

1. **Request Arrives**: User sends request with JWT token
2. **Authentication**: `Authenticatable` concern extracts user from token
3. **Load Resource**: `load_and_authorize_resource` loads the resource
4. **Check Authorization**: CanCanCan calls `Ability.new(current_user)` to check permissions
5. **Grant/Deny**: Either proceeds with action or returns 403 Forbidden

### Permission System

#### Actions
- **manage**: Special action that matches any action
- **read**: View/show/index actions
- **create**: Create new resources
- **update**: Modify existing resources
- **destroy**: Delete resources

#### Subjects
- Class name of the model (e.g., `Event`, `User`, `Ticket`)
- Can use `:all` to match all resources

#### Conditions
Optional hash for dynamic permissions:
```ruby
# User can only update their own events
{ action: 'update', subject_class: 'Event', conditions: { user_id: 'user.id' } }
```

## Implementation Guide

### Step 1: Define Roles and Permissions

Create or update `db/seeds/roles_and_permissions.rb`:

```ruby
# Clear existing data
Role.destroy_all
Permission.destroy_all

# Define roles with their permissions
roles = {
  'superadmin' => {
    description: 'Has full access to all resources and actions.',
    permissions: [] # Will get 'can :manage, :all' in Ability
  },
  'admin' => {
    description: 'Can manage users and read events.',
    permissions: [
      { action: 'read', subject_class: 'User' },
      { action: 'manage', subject_class: 'User' },
      { action: 'read', subject_class: 'Event' }
    ]
  },
  'organizer' => {
    description: 'Can manage their own events.',
    permissions: [
      { action: 'read', subject_class: 'Event' },
      { action: 'create', subject_class: 'Event' },
      { action: 'update', subject_class: 'Event', conditions: { user_id: 'user.id' } },
      { action: 'destroy', subject_class: 'Event', conditions: { user_id: 'user.id' } }
    ]
  },
  'premium_organizer' => {
    description: 'Can manage their own events and create tickets.',
    permissions: [
      { action: 'read', subject_class: 'Event' },
      { action: 'create', subject_class: 'Event' },
      { action: 'update', subject_class: 'Event', conditions: { user_id: 'user.id' } },
      { action: 'destroy', subject_class: 'Event', conditions: { user_id: 'user.id' } },
      { action: 'create', subject_class: 'Ticket' }
    ]
  }
}

# Create roles and permissions
roles.each do |role_name, role_data|
  role = Role.create!(name: role_name, description: role_data[:description])

  role_data[:permissions].each do |perm|
    role.permissions.create!(
      action: perm[:action],
      subject_class: perm[:subject_class],
      conditions: perm[:conditions] || {}
    )
  end
end

puts 'Roles and permissions seeding completed successfully!'
```

### Step 2: Seed the Database

```bash
rails db:seed
```

### Step 3: Update Ability Class (if needed)

The Ability class should handle permission conditions properly:

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    role = user.role
    return cannot :manage, :all if role.blank?
    return can :manage, :all if role.name == 'superadmin'

    # Process role permissions
    role.permissions.each do |permission|
      action = permission.action.to_sym
      model_class = permission.subject_class.classify.safe_constantize
      next unless model_class

      if permission.conditions.present?
        # Dynamic conditions: replace 'user.id' with actual user ID
        conditions = process_conditions(permission.conditions, user)
        can action, model_class, conditions
      else
        can action, model_class
      end
    end
  end

  private

  def process_conditions(conditions, user)
    conditions.deep_symbolize_keys.transform_values do |value|
      value == 'user.id' ? user.id.to_s : value
    end
  end
end
```

### Step 4: Protect Controllers

#### Option A: Automatic (Recommended for CRUD controllers)

```ruby
class Api::V1::Admin::EventsController < Api::V1::Admin::BaseController
  # load_and_authorize_resource is inherited from BaseController
  # Automatically loads @event and checks authorization
  
  def index
    # @events is automatically loaded and filtered by abilities
    render json: @events
  end
  
  def show
    # @event is automatically loaded and authorized
    render json: @event
  end
  
  def create
    # @event is initialized with params and authorized
    if @event.save
      render json: @event, status: :created
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end
end
```

#### Option B: Manual (For custom logic)

```ruby
class Api::V1::Admin::CustomController < Api::V1::Admin::BaseController
  skip_load_and_authorize_resource # Skip automatic loading
  
  def custom_action
    event = Event.find(params[:id])
    authorize! :update, event  # Manual authorization check
    
    # Your custom logic
    result = perform_custom_operation(event)
    render json: result
  end
  
  def bulk_action
    events = Event.where(id: params[:event_ids])
    
    # Authorize each event
    events.each do |event|
      authorize! :destroy, event
    end
    
    # Proceed with bulk operation
    events.destroy_all
    render json: { message: 'Bulk delete successful' }
  end
end
```

### Step 5: Handle Authorization Errors

Add error handling in `ApplicationController`:

```ruby
class ApplicationController < ActionController::API
  rescue_from CanCan::AccessDenied do |exception|
    render json: {
      error: 'Access Denied',
      message: exception.message
    }, status: :forbidden
  end
end
```

## Usage Examples

### Example 1: Basic CRUD Authorization

```ruby
class Api::V1::Admin::CategoriesController < Api::V1::Admin::BaseController
  # Inherits load_and_authorize_resource from BaseController
  
  def index
    # Returns only categories the user can read
    render json: @categories
  end
  
  def create
    if @category.save
      render json: @category, status: :created
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end
end
```

### Example 2: Conditional Authorization

```ruby
# Permission in database:
# { action: 'update', subject_class: 'Event', conditions: { user_id: 'user.id' } }

# This allows organizers to update only their own events
class Api::V1::Admin::EventsController < Api::V1::Admin::BaseController
  def update
    # CanCanCan automatically checks if @event.user_id == current_user.id
    if @event.update(event_params)
      render json: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end
end
```

### Example 3: Custom Authorization Checks

```ruby
class Api::V1::Admin::ReportsController < Api::V1::Admin::BaseController
  skip_load_and_authorize_resource
  
  def financial_report
    # Check if user can manage reports
    authorize! :read, :financial_report
    
    report = generate_financial_report
    render json: report
  end
  
  def export_data
    # Check against model
    authorize! :export, Event
    
    data = export_events_data
    send_data data, filename: 'events.csv'
  end
end
```

### Example 4: Checking Abilities in Views/Serializers

```ruby
class EventSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :can_edit, :can_delete
  
  def can_edit
    scope.can?(:update, object)
  end
  
  def can_delete
    scope.can?(:destroy, object)
  end
end
```

### Example 5: Filtering Resources by Abilities

```ruby
class Api::V1::Admin::EventsController < Api::V1::Admin::BaseController
  def index
    # Get all events accessible to current user
    @events = Event.accessible_by(current_ability)
    render json: @events
  end
end
```

## Testing Authorization

### RSpec Examples

```ruby
# spec/models/ability_spec.rb
require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  describe 'superadmin' do
    let(:role) { create(:role, name: 'superadmin') }
    let(:user) { create(:user, role: role) }
    subject(:ability) { Ability.new(user) }
    
    it { is_expected.to be_able_to(:manage, :all) }
  end
  
  describe 'organizer' do
    let(:role) { create(:role, name: 'organizer') }
    let(:user) { create(:user, role: role) }
    let!(:permission) do
      create(:permission, 
        role: role,
        action: 'update',
        subject_class: 'Event',
        conditions: { user_id: 'user.id' }
      )
    end
    subject(:ability) { Ability.new(user) }
    
    it 'can update own events' do
      own_event = create(:event, user: user)
      expect(ability).to be_able_to(:update, own_event)
    end
    
    it 'cannot update other users events' do
      other_event = create(:event)
      expect(ability).not_to be_able_to(:update, other_event)
    end
  end
  
  describe 'user without role' do
    let(:user) { create(:user, role: nil) }
    subject(:ability) { Ability.new(user) }
    
    it { is_expected.not_to be_able_to(:read, Event) }
    it { is_expected.not_to be_able_to(:manage, :all) }
  end
  
  describe 'guest user' do
    subject(:ability) { Ability.new(nil) }
    
    it { is_expected.not_to be_able_to(:read, Event) }
    it { is_expected.not_to be_able_to(:manage, :all) }
  end
end
```

### Controller Tests

```ruby
# spec/requests/api/v1/admin/events_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Events', type: :request do
  let(:role) { create(:role, name: 'organizer') }
  let(:user) { create(:user, role: role) }
  let(:token) { JwtService.encode(user_id: user.id.to_s) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  
  describe 'GET /api/v1/admin/events' do
    before do
      create(:permission, 
        role: role,
        action: 'read',
        subject_class: 'Event'
      )
    end
    
    it 'returns events when authorized' do
      get '/api/v1/admin/events', headers: headers
      expect(response).to have_http_status(:ok)
    end
  end
  
  describe 'POST /api/v1/admin/events' do
    context 'when user has create permission' do
      before do
        create(:permission, 
          role: role,
          action: 'create',
          subject_class: 'Event'
        )
      end
      
      it 'creates event' do
        post '/api/v1/admin/events',
          params: { event: attributes_for(:event) },
          headers: headers
        expect(response).to have_http_status(:created)
      end
    end
    
    context 'when user lacks create permission' do
      it 'returns forbidden' do
        post '/api/v1/admin/events',
          params: { event: attributes_for(:event) },
          headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
```

## Common Patterns

### Pattern 1: Nested Resources

```ruby
class Api::V1::Admin::Event::TicketsController < Api::V1::Admin::BaseController
  before_action :load_event
  load_and_authorize_resource :ticket, through: :event
  
  private
  
  def load_event
    @event = Event.find(params[:event_id])
    authorize! :read, @event
  end
end
```

### Pattern 2: Scoped Collections

```ruby
class Api::V1::Admin::EventsController < Api::V1::Admin::BaseController
  def index
    # Only get events user can read
    @events = Event.accessible_by(current_ability)
                   .mongodb_search_with_filters(params)
    render json: @events
  end
end
```

### Pattern 3: Dynamic Permissions

```ruby
# Add to Ability class for more complex logic
def initialize(user)
  # ... existing code ...
  
  # Custom business logic
  if user.premium_organizer?
    can :create, Ticket
    can :customize, :ui
  end
  
  # Time-based permissions
  can :early_access, Feature if user.created_at < 1.year.ago
end
```

### Pattern 4: Resource-specific Abilities

```ruby
# In Ability class
def initialize(user)
  # ... existing code ...
  
  # Event-specific abilities
  can :publish, Event do |event|
    event.user_id == user.id && event.draft?
  end
  
  can :archive, Event do |event|
    event.user_id == user.id && event.ended?
  end
end
```

## Troubleshooting

### Issue 1: AccessDenied Errors

**Problem**: Getting 403 Forbidden unexpectedly

**Solutions**:
1. Check if user has a role assigned
2. Verify permissions exist for the role
3. Check condition matching (e.g., `user_id`)
4. Test ability in console:
   ```ruby
   user = User.find('user_id')
   ability = Ability.new(user)
   ability.can?(:update, Event.first)
   ```

### Issue 2: Conditions Not Working

**Problem**: Conditional permissions not being enforced

**Solution**: Ensure conditions are processed in Ability:
```ruby
def process_conditions(conditions, user)
  conditions.deep_symbolize_keys.transform_values do |value|
    case value
    when 'user.id' then user.id.to_s
    when /^user\./ then user.send(value.gsub('user.', ''))
    else value
    end
  end
end
```

### Issue 3: Load Resource Not Working

**Problem**: `load_and_authorize_resource` not loading resource

**Solutions**:
1. Ensure controller follows RESTful naming
2. Manually specify model:
   ```ruby
   load_and_authorize_resource :event, class: 'Event'
   ```
3. Skip for non-standard actions:
   ```ruby
   load_and_authorize_resource except: [:custom_action]
   ```

### Issue 4: Testing Failures

**Problem**: Authorization tests failing

**Solutions**:
1. Create permissions in test setup
2. Use FactoryBot:
   ```ruby
   factory :permission do
     action { 'read' }
     subject_class { 'Event' }
     role
   end
   ```
3. Include CanCan matchers:
   ```ruby
   require 'cancan/matchers'
   ```

## Best Practices

1. **Use Seed Data**: Define all roles and base permissions in seeds
2. **Prefer Database Permissions**: Store permissions in DB for flexibility
3. **Test Thoroughly**: Write tests for each role and permission combination
4. **Handle Guests**: Always check if user is present
5. **Use Descriptive Actions**: Use clear action names (not just CRUD)
6. **Document Changes**: Update this doc when adding new roles/permissions
7. **Audit Permissions**: Regularly review and clean up unused permissions
8. **Use `accessible_by`**: Filter collections by abilities for better security
9. **Avoid Complex Logic**: Keep Ability class simple; use policies for complex rules
10. **Log Authorization**: Log access denied events for security monitoring

## References

- [CanCanCan Documentation](https://github.com/CanCanCommunity/cancancan)
- [MongoDB Role-Based Access Control](https://docs.mongodb.com/manual/core/authorization/)
- [Rails Authorization Best Practices](https://guides.rubyonrails.org/action_controller_overview.html#authorization)

---

**Last Updated**: October 14, 2025
**Version**: 1.0.0
