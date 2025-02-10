class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :starts_at, type: Time
  field :ends_at, type: Time
  field :description, type: String
  field :location, type: String

  validates :title, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true
end
