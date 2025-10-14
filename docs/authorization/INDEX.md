# Authorization System - Documentation Index

Complete documentation for implementing and using the CanCanCan-based authorization system in Blancakan API.

## 📚 Documentation Files

### 1. [README.md](./README.md) - **START HERE**
Complete guide covering:
- Architecture and authorization flow
- Core components (User, Role, Permission, Ability)
- How the system works
- Implementation guide with step-by-step instructions
- Usage examples for common scenarios
- Testing strategies
- Best practices and patterns
- Common pitfalls to avoid

**When to use**: Comprehensive understanding of the entire authorization system.

---

### 2. [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - **CHEAT SHEET**
Quick reference guide with:
- Role hierarchy visualization
- Common actions and their meanings
- Permission structure format
- Code snippets for common operations
- Debugging commands
- HTTP status codes
- Request flow diagram
- Common mistakes and corrections

**When to use**: Quick lookup while coding or debugging.

---

### 3. [COMPLETE_EXAMPLE.md](./COMPLETE_EXAMPLE.md) - **HANDS-ON TUTORIAL**
Step-by-step implementation of authorization for a new resource:
- Complete example: Adding `Report` resource with authorization
- All necessary files (model, controller, service, tests)
- Seeds configuration
- MongoDB search integration
- Testing in console and via API
- Complete checklist

**When to use**: Adding authorization to a new resource from scratch.

---

### 4. [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - **PROBLEM SOLVING**
Solutions for common issues:
- 403 Forbidden errors
- MongoDB text index errors
- Load resource issues
- Condition matching problems
- Test failures
- Performance issues
- Debugging commands and logging

**When to use**: Resolving errors or unexpected authorization behavior.

---

## 🚀 Quick Navigation

### For New Developers
1. Start with [README.md](./README.md) - Read "Architecture" and "How It Works"
2. Follow [COMPLETE_EXAMPLE.md](./COMPLETE_EXAMPLE.md) - Implement a test resource
3. Keep [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) handy while coding

### For Experienced Developers
1. Skim [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) for syntax
2. Reference [COMPLETE_EXAMPLE.md](./COMPLETE_EXAMPLE.md) when adding new resources
3. Use [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) when issues arise

### For Debugging Issues
1. Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) first
2. Use debugging commands from [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
3. Review flow diagram in [README.md](./README.md)

---

## 📖 Key Concepts Summary

### Authorization Flow
```
User Request → Authentication → Authorization → Ability Check → Action or 403
```

### Core Models

**User**: Has one Role
```ruby
user.role  # => Role instance
```

**Role**: Has many Permissions
```ruby
role.permissions  # => [Permission, Permission, ...]
```

**Permission**: Defines what actions can be performed
```ruby
{
  action: 'update',
  subject_class: 'Event',
  conditions: { user_id: 'user.id' }
}
```

**Ability**: Translates permissions into CanCanCan rules
```ruby
can :update, Event, user_id: user.id
```

### Controller Integration

Automatic (recommended):
```ruby
class EventsController < Api::V1::Admin::BaseController
  # load_and_authorize_resource inherited
end
```

Manual (for custom logic):
```ruby
def custom_action
  authorize! :custom_action, resource
end
```

---

## 🔍 Common Tasks

### Check if User Can Perform Action
```ruby
ability = Ability.new(user)
ability.can?(:update, event)
```

### Get Accessible Records
```ruby
Event.accessible_by(current_ability)
```

### Add New Permission
```ruby
# In db/seeds/roles_and_permissions.rb
{ action: 'export', subject_class: 'Report' }
```

### Create Indexes
```bash
bundle exec rake db:mongoid:create_indexes
```

---

## ⚡ Quick Commands

```bash
# Seed roles and permissions
rails db:seed

# Create MongoDB indexes
bundle exec rake db:mongoid:create_indexes

# Test in console
rails console
> user = User.first
> ability = Ability.new(user)
> ability.can?(:read, Event)

# Run tests
rspec spec/models/ability_spec.rb
```

---

## 🎯 Best Practices

1. ✅ Always test authorization with different roles
2. ✅ Use `accessible_by` to filter collections
3. ✅ Keep Ability class simple; extract complex logic to policies
4. ✅ Document custom actions and permissions
5. ✅ Create MongoDB indexes before querying
6. ✅ Use condition strings (`'user.id'`) not values
7. ✅ Test edge cases (no role, no permissions, wrong role)
8. ✅ Log authorization denials for security monitoring

---

## 🐛 Common Issues

| Issue | Quick Fix | Documentation |
|-------|-----------|---------------|
| 403 Forbidden | Check user has role and permissions | [Troubleshooting](./TROUBLESHOOTING.md#403-forbidden-errors) |
| Text index error | Run `rake db:mongoid:create_indexes` | [Troubleshooting](./TROUBLESHOOTING.md#index-text-search-error) |
| Resource not loaded | Use `load_and_authorize_resource` | [README](./README.md#step-4-protect-controllers) |
| Conditions not working | Check string format and types | [Troubleshooting](./TROUBLESHOOTING.md#condition-matching-problems) |
| Test failures | Create permissions in setup | [Troubleshooting](./TROUBLESHOOTING.md#test-failures) |

---

## 📊 System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Authorization System                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User ──has_one──► Role ──has_many──► Permission           │
│    │                                        │                │
│    │                                        │                │
│    │         ┌──────────────────────────────┘                │
│    │         │                                              │
│    └──►  Ability  ◄───loads and processes───┐              │
│              │                                │              │
│              │                                │              │
│         ┌────▼─────────┐                     │              │
│         │  CanCanCan   │                     │              │
│         │  Authorization│                     │              │
│         └────┬─────────┘                     │              │
│              │                                │              │
│         ┌────▼──────────────────────┐        │              │
│         │  Controller               │        │              │
│         │  - load_and_authorize     │────────┘              │
│         │  - authorize!             │                       │
│         └───────────────────────────┘                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔗 Related Documentation

- [API Authentication](../api/authentication.md) - How to get JWT tokens
- [MongoDB Search](../mongodb_search/README.md) - Search permissions
- [Form Objects](../development/form_objects_pattern.md) - Validate permission data
- [Testing Guide](../development/testing.md) - Test authorization

---

## 📞 Support

If you need help:

1. Check the troubleshooting guide first
2. Search existing issues in the repository
3. Review the complete example for similar use cases
4. Contact the development team with:
   - Error message
   - User role
   - Action attempted
   - Relevant code snippets

---

**Last Updated**: October 14, 2025  
**Maintainer**: Blancakan Development Team  
**Version**: 1.0.0
