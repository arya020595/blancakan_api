# Authorization Quick Reference Guide

## Quick Commands

```bash
# Seed roles and permissions
rails db:seed

# Create MongoDB indexes (required for permission search)
bundle exec rake db:mongoid:create_indexes

# Test authorization in console
rails console
> user = User.first
> ability = Ability.new(user)
> ability.can?(:read, Event)
> ability.can?(:update, Event.first)
```

## Role Hierarchy

```
┌─────────────────────────────────────────────────────────┐
│                    Role Hierarchy                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Superadmin (Full Access)                               │
│       │                                                  │
│       ├── can :manage, :all                             │
│       └── No restrictions                               │
│                                                          │
│  Admin                                                   │
│       │                                                  │
│       ├── can :manage, User                             │
│       └── can :read, Event                              │
│                                                          │
│  Premium Organizer                                       │
│       │                                                  │
│       ├── can :manage, Event (own only)                 │
│       ├── can :create, Ticket                           │
│       └── can :customize, UI                            │
│                                                          │
│  Organizer (Default)                                     │
│       │                                                  │
│       ├── can :create, Event                            │
│       ├── can :read, Event                              │
│       ├── can :update, Event (own only)                 │
│       └── can :destroy, Event (own only)                │
│                                                          │
│  No Role / Guest                                         │
│       └── cannot :manage, :all                          │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Common Actions

| Action    | Description                              | Example                          |
|-----------|------------------------------------------|----------------------------------|
| `:manage` | Any action (includes all below)          | `can :manage, Event`            |
| `:read`   | View/index/show actions                  | `can :read, User`               |
| `:create` | Create new resources                     | `can :create, Ticket`           |
| `:update` | Modify existing resources                | `can :update, Event`            |
| `:destroy`| Delete resources                         | `can :destroy, Event`           |
| Custom    | Any custom action you define             | `can :publish, Event`           |

## Permission Structure

```ruby
{
  action: 'update',              # What action can be performed
  subject_class: 'Event',        # On which resource
  conditions: { user_id: 'user.id' }  # Optional: conditions to match
}
```

## Controller Authorization

### Automatic (Recommended)

```ruby
class Api::V1::Admin::EventsController < Api::V1::Admin::BaseController
  # load_and_authorize_resource is inherited
  # Automatically handles authorization for standard CRUD actions
end
```

### Manual

```ruby
class CustomController < Api::V1::Admin::BaseController
  skip_load_and_authorize_resource
  
  def custom_action
    resource = SomeModel.find(params[:id])
    authorize! :custom_action, resource
    # ... your logic
  end
end
```

## Check Abilities in Code

```ruby
# In controllers
if can? :update, @event
  # User can update
end

# In models/services
ability = Ability.new(user)
if ability.can?(:destroy, event)
  # User can destroy
end

# Get accessible records
@events = Event.accessible_by(current_ability)
```

## Common Conditions

```ruby
# Own resources only
conditions: { user_id: 'user.id' }

# Organization-scoped
conditions: { organization_id: 'user.organization_id' }

# Status-based
conditions: { status: 'draft' }

# Multiple conditions (all must match)
conditions: { 
  user_id: 'user.id', 
  status: 'draft' 
}
```

## Adding New Permissions

### 1. Add to Seeds

```ruby
# db/seeds/roles_and_permissions.rb
role.permissions.create!(
  action: 'export',
  subject_class: 'Report',
  conditions: {}
)
```

### 2. Reseed

```bash
rails db:seed
```

### 3. Use in Controller

```ruby
def export
  authorize! :export, Report
  # ... export logic
end
```

## Testing Checklist

```ruby
# spec/models/ability_spec.rb
describe 'Role' do
  let(:user) { create(:user, role: role) }
  subject(:ability) { Ability.new(user) }
  
  it { is_expected.to be_able_to(:action, Model) }
  it { is_expected.not_to be_able_to(:action, Model) }
end
```

## Error Handling

```ruby
# In ApplicationController
rescue_from CanCan::AccessDenied do |exception|
  render json: {
    error: 'Access Denied',
    message: exception.message
  }, status: :forbidden
end
```

## Debugging Authorization

```ruby
# Rails console
user = User.find('user_id')
ability = Ability.new(user)

# Check specific ability
ability.can?(:update, Event.first)  # => true/false

# See all abilities
ability.permissions.each do |permission|
  puts "#{permission.action} #{permission.subject_class}"
end

# Check with conditions
event = Event.first
ability.can?(:update, event)  # Checks conditions too

# Accessible records
Event.accessible_by(ability).count
```

## HTTP Status Codes

| Status | Meaning        | When Used                                |
|--------|----------------|------------------------------------------|
| 200    | OK             | Successful authorized request            |
| 201    | Created        | Resource created successfully            |
| 401    | Unauthorized   | No valid authentication (missing token)  |
| 403    | Forbidden      | Authenticated but not authorized         |
| 404    | Not Found      | Resource doesn't exist or no access      |

## Request Flow

```
1. Request with JWT token
   │
   ▼
2. Authenticatable extracts user
   │
   ▼
3. load_and_authorize_resource
   ├── Loads resource (e.g., @event)
   └── Calls authorize!
       │
       ▼
4. Ability.new(current_user)
   ├── Loads user's role
   ├── Loads role's permissions
   └── Defines can/cannot rules
       │
       ▼
5. CanCanCan checks permission
   ├── Match action + subject
   ├── Check conditions
   └── Return true/false
       │
       ▼
6. Result
   ├── Authorized → Execute action
   └── Denied → Raise CanCan::AccessDenied (403)
```

## API Request Examples

### Authorized Request

```bash
curl -X GET http://localhost:3000/api/v1/admin/events \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Response: 200 OK
{
  "events": [...]
}
```

### Unauthorized Request

```bash
curl -X DELETE http://localhost:3000/api/v1/admin/events/123 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Response: 403 Forbidden
{
  "error": "Access Denied",
  "message": "You are not authorized to access this page."
}
```

## Tips

1. **Always authenticate first**: Authorization requires a valid user
2. **Test with different roles**: Ensure each role has correct permissions
3. **Use accessible_by**: Filter collections instead of showing errors
4. **Log access denials**: Track security issues
5. **Keep it simple**: Complex authorization logic → separate policy class
6. **Document custom actions**: Update docs when adding new actions
7. **Review regularly**: Audit permissions quarterly

## Common Mistakes

❌ **Forgetting to authenticate**
```ruby
# Missing authentication
authorize! :read, Event
```

✅ **Correct**
```ruby
# BaseController includes Authenticatable
class Api::V1::Admin::BaseController < Api::BaseController
  include Authenticatable  # Sets @current_user
  load_and_authorize_resource
end
```

❌ **Wrong condition format**
```ruby
conditions: { user_id: user.id }  # Won't work - evaluated at creation
```

✅ **Correct**
```ruby
conditions: { user_id: 'user.id' }  # String, evaluated at runtime
```

❌ **Testing without permissions**
```ruby
it 'can update event' do
  get :update, params: { id: event.id }
  expect(response).to be_successful
end
```

✅ **Correct**
```ruby
it 'can update event' do
  create(:permission, role: user.role, action: 'update', subject_class: 'Event')
  get :update, params: { id: event.id }
  expect(response).to be_successful
end
```

---

**See [README.md](./README.md) for complete documentation**
