class Category
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  field :status, type: Boolean, default: false
  field :parent_id, type: BSON::ObjectId

  has_many :events
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :subcategories, class_name: 'Category', foreign_key: :parent_id

  validates :name, presence: true, uniqueness: true

  scope :main_categories, -> { where(parent_id: nil) }
  scope :subcategories, -> { where(:parent_id.ne => nil) }
  scope :active, -> { where(status: true) }
  scope :inactive, -> { where(status: false) }
end
