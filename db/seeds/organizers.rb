# frozen_string_literal: true

# Seed file for Organizer model
# Creates sample organizer profiles for testing and development

module OrganizerSeeder
  SAMPLE_ORGANIZERS = [
    {
      handle: '@blancakan_id',
      name: 'Blancakan ID',
      description: 'Organizing curated creative events across Jakarta. Bringing together artists, designers, and creative minds.',
      contact_phone: '+6281234567890'
    },
    {
      handle: '@techjakarta',
      name: 'Tech Jakarta',
      description: 'Premier technology events in Jakarta. Conferences, workshops, and networking for developers.',
      contact_phone: '+6281234567891'
    },
    {
      handle: '@artspace_jkt',
      name: 'ArtSpace Jakarta',
      description: 'Contemporary art exhibitions and cultural events. Showcasing local and international artists.',
      contact_phone: '+6281234567892'
    },
    {
      handle: '@foodie_events',
      name: 'Foodie Events',
      description: 'Culinary experiences and food festivals. Taste the best of Indonesian and international cuisine.',
      contact_phone: '+6281234567893'
    },
    {
      handle: '@wellness_hub',
      name: 'Wellness Hub',
      description: 'Health and wellness workshops, yoga retreats, and mindfulness sessions for urban professionals.',
      contact_phone: '+6281234567894'
    }
  ].freeze

  class << self
    def seed!
      puts '🌱 Seeding Organizer data...'

      validate_prerequisites!

      results = seed_organizers
      display_results(results)
      display_summary
    end

    private

    def validate_prerequisites!
      return if User.exists?

      puts '❌ No users found. Please seed users first.'
      puts '💡 Run: rails db:seed SEED_FILE=users'
      exit(1)
    end

    def seed_organizers
      available_users = users_without_organizers

      if available_users.empty?
        puts '⚠️  All users already have organizer profiles'
        return { created: 0, skipped: User.where(:organizer.exists => true).count, errors: [] }
      end

      results = { created: 0, skipped: 0, errors: [] }

      SAMPLE_ORGANIZERS.each_with_index do |organizer_data, index|
        user = available_users[index]
        break unless user

        result = create_organizer_for_user(user, organizer_data)
        update_results(results, result)
      end

      results
    end

    def users_without_organizers
      @users_without_organizers ||= User.where(:organizer.exists => false)
                                        .limit(SAMPLE_ORGANIZERS.size)
    end

    def create_organizer_for_user(user, organizer_data)
      organizer = user.build_organizer(organizer_data)

      if organizer.save
        puts "✅ Created organizer: #{organizer.handle} (#{organizer.name}) for #{user.email}"
        { status: :created, organizer: organizer }
      else
        error_msg = "Failed to create organizer for #{user.email}: #{organizer.errors.full_messages.join(', ')}"
        puts "❌ #{error_msg}"
        { status: :error, error: error_msg }
      end
    rescue StandardError => e
      error_msg = "Exception creating organizer for #{user.email}: #{e.message}"
      puts "💥 #{error_msg}"
      puts "   📍 #{e.backtrace.first}" if Rails.env.development?
      { status: :error, error: error_msg }
    end

    def update_results(results, result)
      case result[:status]
      when :created
        results[:created] += 1
      when :error
        results[:errors] << result[:error]
      end
    end

    def display_results(results)
      puts "\n📊 Organizer seeding completed!"
      puts "   ✅ Created: #{results[:created]} organizers"
      puts "   ⏭️  Skipped: #{results[:skipped]} (already existed)"
      puts "   ❌ Errors: #{results[:errors].size}"

      return unless results[:errors].any?

      puts "\n🚨 Errors encountered:"
      results[:errors].each_with_index do |error, index|
        puts "   #{index + 1}. #{error}"
      end
    end

    def display_summary
      total_count = Organizer.count
      puts "   📈 Total organizers: #{total_count}"

      return unless total_count > 0

      puts "\n📋 Current organizers:"

      Organizer.includes(:user).each do |organizer|
        status_icon = organizer.is_active ? '🟢' : '🔴'
        status_text = organizer.is_active ? 'Active' : 'Inactive'
        user_email = organizer.user&.email || 'No user'

        puts "   #{status_icon} #{organizer.handle.ljust(20)} | #{organizer.name.ljust(25)} | #{status_text.ljust(8)} | #{user_email}"
      end

      display_statistics
    end

    def display_statistics
      stats = calculate_statistics

      puts "\n📈 Statistics:"
      puts "   Active organizers: #{stats[:active]} (#{stats[:active_percentage]}%)"
      puts "   Inactive organizers: #{stats[:inactive]} (#{stats[:inactive_percentage]}%)"
      puts "   Average events per organizer: #{stats[:avg_events]}"
    end

    def calculate_statistics
      total = Organizer.count
      active = Organizer.where(is_active: true).count
      inactive = total - active
      total_events = Event.count

      {
        active: active,
        inactive: inactive,
        active_percentage: total > 0 ? (active * 100.0 / total).round(1) : 0,
        inactive_percentage: total > 0 ? (inactive * 100.0 / total).round(1) : 0,
        avg_events: total > 0 ? (total_events / total.to_f).round(1) : 0
      }
    end
  end
end

# Execute the seeder
OrganizerSeeder.seed!
