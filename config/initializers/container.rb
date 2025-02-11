require 'dry/container'

class Container
  extend Dry::Container::Mixin

  register(:v1_role_service) { V1::RoleService.new }
  register(:v1_permission_service) { V1::PermissionService.new }
end
