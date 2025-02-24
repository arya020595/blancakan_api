require 'rails_helper'

RSpec.describe Permission, type: :model do
  let(:role) { create(:role) }

  # Test that a permission is valid with valid attributes
  it 'is valid with valid attributes' do
    permission = Permission.new(
      action: 'read',
      subject_class: 'User',
      role: role
    )
    expect(permission).to be_valid
  end

  # Test that a permission is not valid without an action
  it 'is not valid without an action' do
    permission = Permission.new(
      action: nil,
      subject_class: 'User',
      role: role
    )
    expect(permission).to_not be_valid
  end

  # Test that a permission is not valid without a subject_class
  it 'is not valid without a subject_class' do
    permission = Permission.new(
      action: 'read',
      subject_class: nil,
      role: role
    )
    expect(permission).to_not be_valid
  end

  # Test that a permission is not valid without a role
  it 'is not valid without a role' do
    permission = Permission.new(
      action: 'read',
      subject_class: 'User',
      role: nil
    )
    expect(permission).to_not be_valid
  end

  # Test that a permission is not valid with a duplicate action and subject_class for the same role
  it 'is not valid with a duplicate action and subject_class for the same role' do
    Permission.create(
      action: 'read',
      subject_class: 'User',
      role: role
    )
    permission = Permission.new(
      action: 'read',
      subject_class: 'User',
      role: role
    )
    expect(permission).to_not be_valid
  end
end
