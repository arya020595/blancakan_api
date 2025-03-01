require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      role = Role.new(name: 'admin', description: 'Administrator role')
      expect(role).to be_valid
    end

    it 'is not valid without a name' do
      role = Role.new(description: 'Administrator role')
      expect(role).not_to be_valid
    end

    it 'is not valid without a description' do
      role = Role.new(name: 'admin')
      expect(role).not_to be_valid
    end

    it 'is not valid with a duplicate name' do
      Role.create(name: 'admin', description: 'Administrator role')
      role = Role.new(name: 'admin', description: 'Another admin role')
      expect(role).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many users' do
      assoc = Role.relations['users']
      expect(assoc.relation).to eq Mongoid::Association::Referenced::HasMany::Proxy
    end
  end
end
