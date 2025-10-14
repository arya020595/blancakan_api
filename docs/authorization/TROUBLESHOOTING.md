# Authorization Troubleshooting Guide

Common issues and solutions when working with the authorization system.

## Table of Contents

1. [403 Forbidden Errors](#403-forbidden-errors)
2. [Index Text Search Error](#index-text-search-error)
3. [Load Resource Issues](#load-resource-issues)
4. [Condition Matching Problems](#condition-matching-problems)
5. [Test Failures](#test-failures)
6. [Performance Issues](#performance-issues)

---

## 403 Forbidden Errors

### Symptom
```json
{
  "error": "Access Denied",
  "message": "You are not authorized to access this page."
}
```

### Common Causes & Solutions

#### 1. User Has No Role

**Check:**
```ruby
user = User.find('user_id')
user.role  # => nil
```

**Solution:**
```ruby
# Set default role in User model
def set_default_role
  self.role ||= Role.find_or_create_by(name: 'organizer')
end

# Or manually assign
user.update(role: Role.find_by(name: 'organizer'))
```

#### 2. Role Has No Permissions

**Check:**
```ruby
role = Role.find_by(name: 'organizer')
role.permissions.count  # => 0
```

**Solution:**
```bash
# Reseed the database
rails db:seed
```

#### 3. Permission Not Matching Action

**Check:**
```ruby
ability = Ability.new(user)
ability.can?(:update, Event)  # => false
```

**Debug:**
```ruby
# Check what permissions user has
user.role.permissions.each do |perm|
  puts "#{perm.action} #{perm.subject_class}"
end
```

**Solution:**
Add missing permission to seeds and reseed:
```ruby
role.permissions.create!(
  action: 'update',
  subject_class: 'Event'
)
```

#### 4. Wrong Subject Class Name

**Problem:**
```ruby
# Permission in DB
{ action: 'read', subject_class: 'Events' }  # Wrong - plural

# Model
class Event  # Singular
```

**Solution:**
Use singular, classified model name:
```ruby
{ action: 'read', subject_class: 'Event' }  # Correct
```

---

## Index Text Search Error

### Symptom
```
Mongo::Error::OperationFailure ([27:IndexNotFound]: text index required for $text query)
```

### Cause
MongoDB text index not created for the model.

### Solution

#### 1. Verify Index Definition in Model

```ruby
# app/models/permission.rb
class Permission
  # ...
  index({ action: 'text', subject_class: 'text' }, { background: true })
end
```

#### 2. Create Indexes

```bash
# Run the rake task to create all indexes
bundle exec rake db:mongoid:create_indexes
```

#### 3. Verify Index Creation

```ruby
# Rails console
Permission.collection.indexes.to_a
# Should see text index on action and subject_class
```

#### 4. Manual Index Creation (if needed)

```ruby
# Rails console
Permission.create_indexes
```

#### 5. Update Searchable Configuration

Ensure the searchable concern matches the index:

```ruby
# app/models/concerns/mongodb_search/permission_searchable.rb
module MongodbSearch
  module PermissionSearchable
    module ClassMethods
      def mongodb_text_fields
        %w[action subject_class]  # Must match index fields
      end
    end
  end
end
```

---

## Load Resource Issues

### Symptom
`@resource` is nil or not loaded in controller action.

### Common Causes & Solutions

#### 1. Non-RESTful Action Names

**Problem:**
```ruby
def custom_export  # CanCanCan doesn't recognize this
  # @event is nil
end
```

**Solution:**
```ruby
def custom_export
  @event = Event.find(params[:id])
  authorize! :export, @event
end
```

#### 2. Custom Resource Name

**Problem:**
```ruby
class EventsController < BaseController
  # Expects @event but uses different name
end
```

**Solution:**
```ruby
load_and_authorize_resource :event, class: 'Event'
# Or manually load:
before_action :load_event, only: [:show, :update]

def load_event
  @event = Event.find(params[:id])
  authorize! params[:action].to_sym, @event
end
```

#### 3. Nested Resources

**Problem:**
```ruby
# /events/:event_id/tickets/:id
# Can't find ticket without event context
```

**Solution:**
```ruby
class Event::TicketsController < BaseController
  before_action :load_event
  load_and_authorize_resource :ticket, through: :event

  private

  def load_event
    @event = Event.find(params[:event_id])
  end
end
```

---

## Condition Matching Problems

### Symptom
User should have access based on conditions, but authorization fails.

### Common Issues

#### 1. String vs Symbol Keys

**Problem:**
```ruby
# Permission conditions stored as strings
{ "user_id" => "user.id" }

# But checking with symbols
{ user_id: current_user.id }
```

**Solution:**
Use `deep_symbolize_keys` in Ability:
```ruby
def process_conditions(conditions, user)
  conditions.deep_symbolize_keys.transform_values do |value|
    value == 'user.id' ? user.id.to_s : value
  end
end
```

#### 2. Type Mismatch (String vs BSON::ObjectId)

**Problem:**
```ruby
# Event.user_id is BSON::ObjectId
# But comparing with String
{ user_id: user.id.to_s }  # String
```

**Solution:**
Ensure consistent types:
```ruby
def process_conditions(conditions, user)
  conditions.deep_symbolize_keys.transform_values do |value|
    if value == 'user.id'
      # Convert to string for MongoDB comparison
      user.id.to_s
    else
      value
    end
  end
end
```

#### 3. Condition Not Evaluated

**Problem:**
```ruby
# Condition stored as actual value instead of placeholder
{ user_id: '507f1f77bcf86cd799439011' }  # Static ID
```

**Solution:**
Store as string placeholder:
```ruby
# In seeds
{ user_id: 'user.id' }  # Will be replaced at runtime
```

#### 4. Multiple Conditions Not Matching

**Problem:**
```ruby
# All conditions must match
{ user_id: 'user.id', status: 'draft' }
# But event.status != 'draft'
```

**Debug:**
```ruby
ability = Ability.new(user)
event = Event.first

# Check conditions
conditions = permission.conditions.deep_symbolize_keys
puts "Required: #{conditions}"
puts "Event user_id: #{event.user_id}"
puts "Event status: #{event.status}"
puts "Can access: #{ability.can?(:update, event)}"
```

---

## Test Failures

### Issue 1: Permissions Not Created in Tests

**Symptom:**
```ruby
it 'updates event' do
  put :update, params: { id: event.id }
  expect(response).to be_successful
end
# Failure: 403 Forbidden
```

**Solution:**
```ruby
it 'updates event' do
  create(:permission,
    role: user.role,
    action: 'update',
    subject_class: 'Event'
  )
  
  put :update, params: { id: event.id }
  expect(response).to be_successful
end
```

### Issue 2: CanCan Matchers Not Available

**Symptom:**
```ruby
it { is_expected.to be_able_to(:read, Event) }
# NoMethodError: undefined method `be_able_to'
```

**Solution:**
```ruby
# spec/rails_helper.rb or spec/spec_helper.rb
require 'cancan/matchers'
```

### Issue 3: Current Ability Not Available

**Symptom:**
```ruby
Event.accessible_by(current_ability)
# NameError: undefined local variable or method `current_ability'
```

**Solution:**
```ruby
# In controller specs
let(:ability) { Ability.new(user) }

# Use in expectations
expect(Event.accessible_by(ability).count).to eq(1)
```

---

## Performance Issues

### Issue 1: Slow Authorization Checks

**Symptom:**
API response time > 500ms due to authorization overhead.

**Solutions:**

#### 1. Index Permission Fields
```ruby
# In Permission model
index({ role_id: 1 }, { background: true })
index({ action: 1, subject_class: 1, role_id: 1 }, { unique: true, background: true })
```

#### 2. Eager Load Associations
```ruby
# In controller
def index
  @events = Event.includes(:user, :organizer)
                 .accessible_by(current_ability)
end
```

#### 3. Cache Abilities
```ruby
# In ApplicationController
def current_ability
  @current_ability ||= Ability.new(current_user)
end
```

### Issue 2: N+1 Queries in Authorization

**Symptom:**
Multiple DB queries when checking authorization for collections.

**Solution:**
```ruby
# Instead of checking each individually
events.each do |event|
  authorize! :read, event  # N queries
end

# Use accessible_by
@events = Event.accessible_by(current_ability)  # 1 query
```

### Issue 3: Complex Ability Conditions

**Symptom:**
Ability class has complex nested logic causing slow performance.

**Solution:**
Extract to policy class:
```ruby
# app/policies/event_policy.rb
class EventPolicy
  def initialize(user, event)
    @user = user
    @event = event
  end

  def can_publish?
    @event.user_id == @user.id && 
    @event.draft? && 
    @event.complete?
  end
end

# In Ability
can :publish, Event do |event|
  EventPolicy.new(user, event).can_publish?
end
```

---

## Debugging Commands

### Check User's Role and Permissions

```ruby
user = User.find('user_id')
puts "Role: #{user.role&.name}"
puts "Permissions:"
user.role&.permissions&.each do |perm|
  puts "  - #{perm.action} #{perm.subject_class} #{perm.conditions}"
end
```

### Check Ability

```ruby
ability = Ability.new(user)

# Check specific ability
ability.can?(:read, Event)
ability.can?(:update, Event.first)

# Get accessible records
Event.accessible_by(ability).count

# Debug permissions
ability.instance_variable_get(:@rules).each do |rule|
  puts "#{rule.base_behavior} #{rule.actions} #{rule.subjects}"
end
```

### Check MongoDB Indexes

```ruby
# List all indexes for Permission model
Permission.collection.indexes.each do |index|
  puts index.inspect
end

# Check if text index exists
text_indexes = Permission.collection.indexes.select { |idx| idx['key'].values.include?('text') }
puts "Text indexes: #{text_indexes.count}"
```

### Check Permission Records

```ruby
# List all permissions for a role
role = Role.find_by(name: 'organizer')
role.permissions.each do |perm|
  puts "Action: #{perm.action}"
  puts "Subject: #{perm.subject_class}"
  puts "Conditions: #{perm.conditions}"
  puts "---"
end
```

### Test Authorization in Console

```ruby
# Setup
user = User.first
event = Event.first
ability = Ability.new(user)

# Test
puts "Can read: #{ability.can?(:read, event)}"
puts "Can update: #{ability.can?(:update, event)}"
puts "Can destroy: #{ability.can?(:destroy, event)}"

# With conditions
own_event = Event.find_by(user_id: user.id)
other_event = Event.where(:user_id.ne => user.id).first

puts "Can update own event: #{ability.can?(:update, own_event)}"
puts "Can update other event: #{ability.can?(:update, other_event)}"
```

---

## Logging Authorization Issues

Add logging to track authorization denials:

```ruby
# config/initializers/authorization_logger.rb
Rails.application.config.to_prepare do
  CanCan::ControllerAdditions.module_eval do
    def authorize_with_logging!(action, subject, *args)
      authorize!(action, subject, *args)
    rescue CanCan::AccessDenied => e
      Rails.logger.warn(
        "Authorization denied: " \
        "User #{current_user&.id} " \
        "attempted #{action} on #{subject.class.name} " \
        "#{subject.try(:id)}"
      )
      raise
    end
  end
end
```

---

## Quick Fix Checklist

When facing authorization issues, check in this order:

1. ✅ User is authenticated (has valid JWT token)
2. ✅ User has a role assigned
3. ✅ Role has permissions
4. ✅ Permission action matches controller action
5. ✅ Permission subject_class matches model name (singular)
6. ✅ MongoDB indexes created (`rake db:mongoid:create_indexes`)
7. ✅ Conditions format correct (string placeholder, not actual values)
8. ✅ Type matching (String vs ObjectId)
9. ✅ Controller extends BaseController with `load_and_authorize_resource`
10. ✅ Tests create necessary permissions

---

## Getting Help

If you've tried everything and still have issues:

1. **Check logs**: `tail -f log/development.log`
2. **Test in console**: Follow debugging commands above
3. **Review permissions**: Verify database records
4. **Check indexes**: Ensure MongoDB indexes exist
5. **Simplify**: Test with superadmin role first
6. **Ask for help**: Provide error message, user role, and action attempted

---

**See [README.md](./README.md) for complete documentation**
