require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:category) { create(:category) }
  let(:user) { create(:user) }

  # Test that an event is valid with valid attributes
  it 'is valid with valid attributes' do
    event = Event.new(
      title: 'Sample Event',
      description: 'Sample description',
      location: 'Sample location',
      starts_at: DateTime.now + 1.day,
      ends_at: DateTime.now + 2.days,
      organizer: 'Sample organizer',
      category: category,
      user: user
    )
    expect(event).to be_valid
  end

  # Test that an event is not valid without a title
  it 'is not valid without a title' do
    event = Event.new(
      title: nil,
      description: 'Sample description',
      location: 'Sample location',
      starts_at: DateTime.now + 1.day,
      ends_at: DateTime.now + 2.days,
      organizer: 'Sample organizer',
      category: category,
      user: user
    )
    expect(event).to_not be_valid
  end

  # Test that an event is not valid without a description
  it 'is not valid without a description' do
    event = Event.new(
      title: 'Sample Event',
      description: nil,
      location: 'Sample location',
      starts_at: DateTime.now + 1.day,
      ends_at: DateTime.now + 2.days,
      organizer: 'Sample organizer',
      category: category,
      user: user
    )
    expect(event).to_not be_valid
  end

  # Test that an event is not valid without a location
  it 'is not valid without a location' do
    event = Event.new(
      title: 'Sample Event',
      description: 'Sample description',
      location: nil,
      starts_at: DateTime.now + 1.day,
      ends_at: DateTime.now + 2.days,
      organizer: 'Sample organizer',
      category: category,
      user: user
    )
    expect(event).to_not be_valid
  end

  # Test that an event is not valid without a start date
  it 'is not valid without a start date' do
    event = Event.new(
      title: 'Sample Event',
      description: 'Sample description',
      location: 'Sample location',
      starts_at: nil,
      ends_at: DateTime.now + 2.days,
      organizer: 'Sample organizer',
      category: category,
      user: user
    )
    expect(event).to_not be_valid
  end

  # Test that an event is not valid without an end date
  it 'is not valid without an end date' do
    event = Event.new(
      title: 'Sample Event',
      description: 'Sample description',
      location: 'Sample location',
      starts_at: DateTime.now + 1.day,
      ends_at: nil,
      organizer: 'Sample organizer',
      category: category,
      user: user
    )
    expect(event).to_not be_valid
  end

  # Test that an event is not valid without an organizer
  it 'is not valid without an organizer' do
    event = Event.new(
      title: 'Sample Event',
      description: 'Sample description',
      location: 'Sample location',
      starts_at: DateTime.now + 1.day,
      ends_at: DateTime.now + 2.days,
      organizer: nil,
      category: category,
      user: user
    )
    expect(event).to_not be_valid
  end

  # Test that an event is not valid with a past start date
  it 'is not valid with a past start date' do
    event = Event.new(
      title: 'Sample Event',
      description: 'Sample description',
      location: 'Sample location',
      starts_at: DateTime.now - 1.day,
      ends_at: DateTime.now + 1.day,
      organizer: 'Sample organizer',
      category: category,
      user: user
    )
    expect(event).to_not be_valid
  end

  # Test that an event is not valid with a start date after the end date
  it 'is not valid with a start date after the end date' do
    event = Event.new(
      title: 'Sample Event',
      description: 'Sample description',
      location: 'Sample location',
      starts_at: DateTime.now + 2.days,
      ends_at: DateTime.now + 1.day,
      organizer: 'Sample organizer',
      category: category,
      user: user
    )
    expect(event).to_not be_valid
  end

  # Test that an event can transition from draft to published
  it 'can transition from draft to published' do
    event = Event.create(
      title: 'Sample Event',
      description: 'Sample description',
      location: 'Sample location',
      starts_at: DateTime.now + 1.day,
      ends_at: DateTime.now + 2.days,
      organizer: 'Sample organizer',
      category: category,
      user: user
    )
    expect(event.status).to eq('draft')
    event.publish!
    expect(event.status).to eq('published')
  end

  # Test that an event can transition from draft to canceled
  it 'can transition from draft to canceled' do
    event = Event.create(
      title: 'Sample Event',
      description: 'Sample description',
      location: 'Sample location',
      starts_at: DateTime.now + 1.day,
      ends_at: DateTime.now + 2.days,
      organizer: 'Sample organizer',
      category: category,
      user: user
    )
    expect(event.status).to eq('draft')
    event.cancel!
    expect(event.status).to eq('canceled')
  end

  # Test that an event can transition from published to canceled
  it 'can transition from published to canceled' do
    event = Event.create(
      title: 'Sample Event',
      description: 'Sample description',
      location: 'Sample location',
      starts_at: DateTime.now + 1.day,
      ends_at: DateTime.now + 2.days,
      organizer: 'Sample organizer',
      category: category,
      user: user
    )
    event.publish!
    expect(event.status).to eq('published')
    event.cancel!
    expect(event.status).to eq('canceled')
  end
end
