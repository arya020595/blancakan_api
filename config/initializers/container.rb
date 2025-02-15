require 'dry/container'

class Container
  extend Dry::Container::Mixin

  register('v1.role_service') { V1::RoleService.new }
  register('v1.permission_service') { V1::PermissionService.new }
  register('v1.user_service') { V1::UserService.new }
end
