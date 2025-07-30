# frozen_string_literal: true

class TicketType
  include Mongoid::Document
  include Mongoid::Timestamps
  include StatusMethods

  field :name, type: String
  field :description, type: String
  field :price, type: Integer
  field :quota, type: Integer
  field :available_from, type: DateTime
  field :available_until, type: DateTime
  field :valid_on, type: DateTime
  field :is_active, type: Boolean, default: true
  field :sort_order, type: Integer
  field :metadata, type: String

  belongs_to :event

  validates :name, :price, :quota, :event, :available_from, :available_until, :valid_on, presence: true
  validates :price, :quota, :sort_order, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(is_active: true) }
  scope :available, -> { where(:available_from.lte => Time.current, :available_until.gte => Time.current) }

  # Search functionality using MongoDB text search
  def self.search(query: '*', page: 1, per_page: 10)
    if query == '*' || query.blank?
      page(page).per(per_page)
    else
      where('$text' => { '$search' => query })
        .page(page).per(per_page)
    end
  end
end
