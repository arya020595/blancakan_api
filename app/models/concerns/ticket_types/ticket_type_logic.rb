# TicketTypeLogic Concern
# Contains business logic for TicketType model

module TicketTypeLogic
  extend ActiveSupport::Concern

  included do
    # ... any callbacks or additional setup ...
  end

  def available_for_purchase?
    is_active && Time.current >= available_from && Time.current <= available_until && quota > 0
  end

  def sold_out?
    quota <= 0
  end

  def group_key
    valid_on.to_date
  end

  module ClassMethods
    def for_event(event_id)
      where(event_id: event_id).active.available.order_by(sort_order: :asc)
    end
  end
end
