# frozen_string_literal: true

require 'bcrypt'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Locker
  include Elasticsearch::UserSearchable

  field :locker_locked_at, type: Time
  field :locker_locked_until, type: Time

  locker locked_at_field: :locker_locked_at

  # Core fields
  field :email,              type: String, default: ''
  field :password_digest,    type: String
  field :name, type: String

  # Password authentication
  attr_reader :password
  attr_accessor :password_confirmation

  validates :password, presence: true, confirmation: true, if: :password_required?
  validates :email, presence: true

  before_save :encrypt_password, if: :password_required?

  def authenticate(unencrypted_password)
    BCrypt::Password.new(password_digest) == unencrypted_password
  rescue StandardError
    false
  end

  def password=(new_password)
    @password = new_password
    self.password_digest = BCrypt::Password.create(new_password) if new_password.present?
  end

  # Database indexes
  index({ email: 1 }, { name: 'email_index', unique: true, background: true })

  # Associations
  has_many :events
  belongs_to :role, optional: true

  # Callbacks
  before_validation :set_default_role, on: :create
  after_create :enqueue_reindex_job
  after_update :enqueue_reindex_job, if: :should_reindex?
  after_destroy :enqueue_reindex_job

  private

  def set_default_role
    self.role ||= Role.find_or_create_by(name: 'organizer')
  end

  def enqueue_reindex_job
    ReindexElasticsearchJob.perform_later(self.class.name, id.to_s)
  end

  def should_reindex?
    saved_change_to_email? || saved_change_to_name? || saved_change_to_role_id?
  end

  def password_required?
    password_digest.blank? || !@password.nil?
  end

  def encrypt_password
    self.password_digest = BCrypt::Password.create(@password) if @password.present?
  end
end
