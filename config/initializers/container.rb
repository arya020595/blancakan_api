require 'dry/container'

class Container
  extend Dry::Container::Mixin

  register('v1.role_service') { V1::RoleService.new }
  register('v1.permission_service') { V1::PermissionService.new }
  register('v1.user_service') { V1::UserService.new }
  register('v1.organizer_service') { V1::OrganizerService.new }
  register('v1.event_service') { V1::EventService.new }
  register('v1.category_service') { V1::CategoryService.new }
  register('v1.event_type_service') { V1::EventTypeService.new }
  register('v1.ticket_type_service') { V1::TicketTypeService.new }
end
