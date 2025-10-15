# Complete Authorization Implementation Example

This document provides a complete, working example of implementing authorization for a new resource from scratch.

## Scenario

We want to add authorization for a new `Report` resource with the following requirements:

- Superadmins can do anything
- Admins can view all reports and create reports
- Organizers can only view and create their own reports
- Premium organizers can additionally export reports

## Step-by-Step Implementation

### Step 1: Create the Model

```ruby
# app/models/report.rb
class Report
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, type: String
  field :content, type: String
  field :report_type, type: String
  field :user_id, type: String

  belongs_to :user

  validates :title, :report_type, presence: true

  index({ user_id: 1 })
  index({ report_type: 1 })
end
```

### Step 2: Define Permissions in Seeds

```ruby
# db/seeds/roles_and_permissions.rb
# Add to existing roles hash:

roles = {
  'superadmin' => {
    description: 'Has full access to all resources and actions.',
    permissions: [] # Gets 'can :manage, :all'
  },
  'admin' => {
    description: 'Can manage users and read events.',
    permissions: [
      # ... existing permissions ...
      { action: 'read', subject_class: 'Report' },
      { action: 'create', subject_class: 'Report' }
    ]
  },
  'organizer' => {
    description: 'Can manage their own events.',
    permissions: [
      # ... existing permissions ...
      { action: 'read', subject_class: 'Report', conditions: { user_id: 'user.id' } },
      { action: 'create', subject_class: 'Report' }
    ]
  },
  'premium_organizer' => {
    description: 'Can manage their own events and create tickets.',
    permissions: [
      # ... existing permissions ...
      { action: 'read', subject_class: 'Report', conditions: { user_id: 'user.id' } },
      { action: 'create', subject_class: 'Report' },
      { action: 'export', subject_class: 'Report', conditions: { user_id: 'user.id' } }
    ]
  }
}

# ... rest of seed file ...
```

### Step 3: Run Seeds

```bash
# Clear and reseed
rails db:seed
```

### Step 4: Update Ability (if needed)

The existing `Ability` class should handle this automatically, but you can add custom logic:

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    role = user.role
    return cannot :manage, :all if role.blank?
    return can :manage, :all if role.name == 'superadmin'

    # Process role permissions (handles Report automatically)
    role.permissions.each do |permission|
      action = permission.action.to_sym
      model_class = permission.subject_class.classify.safe_constantize
      next unless model_class

      if permission.conditions.present?
        conditions = process_conditions(permission.conditions, user)
        can action, model_class, conditions
      else
        can action, model_class
      end
    end
    
    # Optional: Add custom business logic
    can :archive, Report do |report|
      report.user_id == user.id && report.created_at < 30.days.ago
    end
  end

  private

  def process_conditions(conditions, user)
    conditions.deep_symbolize_keys.transform_values do |value|
      case value
      when 'user.id' then user.id.to_s
      when /^user\./ then user.send(value.gsub('user.', ''))
      else value
      end
    end
  end
end
```

### Step 5: Create Controller

```ruby
# app/controllers/api/v1/admin/reports_controller.rb
module Api
  module V1
    module Admin
      class ReportsController < Api::V1::Admin::BaseController
        # load_and_authorize_resource is inherited from BaseController
        # It will automatically:
        # - Load @report for show, update, destroy
        # - Initialize @report for create
        # - Load and filter @reports for index
        # - Check authorization for each action

        def index
          # @reports is automatically filtered by accessible_by
          result = @report_service.index(params)
          format_response(result: result, resource: 'reports', action: :index)
        end

        def show
          # @report is automatically loaded and authorized
          result = @report_service.show(@report)
          format_response(result: result, resource: 'reports', action: :show)
        end

        def create
          # @report is initialized and authorized
          result = @report_service.create(report_params)
          format_response(result: result, resource: 'reports', action: :create)
        end

        def update
          # @report is loaded and authorized
          result = @report_service.update(@report, report_params)
          format_response(result: result, resource: 'reports', action: :update)
        end

        def destroy
          # @report is loaded and authorized
          result = @report_service.destroy(@report)
          format_response(result: result, resource: 'reports', action: :destroy)
        end

        # Custom action with manual authorization
        def export
          authorize! :export, Report  # Manual check for custom action
          
          # Only get reports user can export
          reports = Report.accessible_by(current_ability, :export)
          
          csv_data = generate_csv(reports)
          send_data csv_data, filename: "reports_#{Date.today}.csv"
        end

        private

        def report_params
          params.require(:report).permit(:title, :content, :report_type)
        end

        def generate_csv(reports)
          # CSV generation logic
        end
      end
    end
  end
end
```

### Step 6: Add Routes

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    namespace :admin do
      resources :reports do
        collection do
          get :export
        end
      end
    end
  end
end
```

### Step 7: Create Service

```ruby
# app/services/v1/report_service.rb
module V1
  class ReportService
    include Dry::Monads[:result]

    def index(params = {})
      reports = ::Report.mongodb_search_with_filters(params)
      Success(reports)
    end

    def show(report)
      return Failure(nil) unless report

      Success(report)
    end

    def create(params)
      form = ::V1::Report::ReportForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      report = ::Report.new(form.attributes)
      if report.save
        Success(report)
      else
        Failure(report.errors.full_messages)
      end
    end

    def update(report, params)
      form = ::V1::Report::ReportForm.new(params)
      return Failure(form.errors.to_hash) unless form.valid?

      if report.update(form.attributes)
        Success(report)
      else
        Failure(report.errors.full_messages)
      end
    end

    def destroy(report)
      return Failure(nil) unless report

      if report.destroy
        Success(report)
      else
        Failure(report.errors.full_messages)
      end
    end
  end
end
```

### Step 8: Create Form Object

```ruby
# app/forms/v1/report/report_form.rb
module V1
  module Report
    class ReportForm < ApplicationForm
      attribute :title, :string
      attribute :content, :string
      attribute :report_type, :string
      attribute :user_id, :string

      validates :title, :report_type, presence: true
      validates :report_type, inclusion: { in: %w[financial event user] }
    end
  end
end
```

### Step 9: Create Serializer

```ruby
# app/serializers/api/v1/admin/report_serializer.rb
module Api
  module V1
    module Admin
      class ReportSerializer < ActiveModel::Serializer
        attributes :id, :title, :content, :report_type, :user_id,
                   :created_at, :updated_at, :can_update, :can_delete, :can_export

        def can_update
          scope.can?(:update, object)
        end

        def can_delete
          scope.can?(:destroy, object)
        end

        def can_export
          scope.can?(:export, object)
        end
      end
    end
  end
end
```

### Step 10: Add MongoDB Search Support

```ruby
# app/models/concerns/mongodb_search/report_searchable.rb
module MongodbSearch
  module ReportSearchable
    extend ActiveSupport::Concern
    include BaseSearchable

    module ClassMethods
      def mongodb_searchable_fields
        %w[title content report_type]
      end

      def mongodb_sortable_fields
        %w[title report_type created_at updated_at _id]
      end

      def mongodb_text_fields
        %w[title content]
      end

      def mongodb_boolean_fields
        []
      end

      def mongodb_filterable_fields
        %w[title report_type user_id created_at updated_at]
      end

      def mongodb_default_sort
        { created_at: -1 }
      end
    end
  end
end
```

```ruby
# Update app/models/report.rb to include the concern
class Report
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongodbSearch::ReportSearchable  # Add this

  # ... rest of model ...
end
```

### Step 11: Register Service in Container

```ruby
# config/initializers/container.rb
# Add to existing container configuration:

Container.register('v1.report_service') do
  V1::ReportService.new
end
```

### Step 12: Write Tests

```ruby
# spec/models/ability_spec.rb
require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  describe 'Report permissions' do
    describe 'admin role' do
      let(:role) { create(:role, name: 'admin') }
      let(:user) { create(:user, role: role) }
      
      before do
        create(:permission, role: role, action: 'read', subject_class: 'Report')
        create(:permission, role: role, action: 'create', subject_class: 'Report')
      end
      
      subject(:ability) { Ability.new(user) }

      it { is_expected.to be_able_to(:read, Report) }
      it { is_expected.to be_able_to(:create, Report) }
      it { is_expected.not_to be_able_to(:update, Report) }
      it { is_expected.not_to be_able_to(:destroy, Report) }
    end

    describe 'organizer role' do
      let(:role) { create(:role, name: 'organizer') }
      let(:user) { create(:user, role: role) }
      
      before do
        create(:permission,
          role: role,
          action: 'read',
          subject_class: 'Report',
          conditions: { user_id: 'user.id' }
        )
        create(:permission,
          role: role,
          action: 'create',
          subject_class: 'Report'
        )
      end
      
      subject(:ability) { Ability.new(user) }

      it 'can read own reports' do
        own_report = create(:report, user: user)
        expect(ability).to be_able_to(:read, own_report)
      end

      it 'cannot read other users reports' do
        other_report = create(:report)
        expect(ability).not_to be_able_to(:read, other_report)
      end

      it 'can create reports' do
        expect(ability).to be_able_to(:create, Report)
      end
    end

    describe 'premium_organizer role' do
      let(:role) { create(:role, name: 'premium_organizer') }
      let(:user) { create(:user, role: role) }
      
      before do
        create(:permission,
          role: role,
          action: 'export',
          subject_class: 'Report',
          conditions: { user_id: 'user.id' }
        )
      end
      
      subject(:ability) { Ability.new(user) }

      it 'can export own reports' do
        own_report = create(:report, user: user)
        expect(ability).to be_able_to(:export, own_report)
      end

      it 'cannot export other users reports' do
        other_report = create(:report)
        expect(ability).not_to be_able_to(:export, other_report)
      end
    end
  end
end
```

```ruby
# spec/requests/api/v1/admin/reports_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Reports', type: :request do
  let(:role) { create(:role, name: 'organizer') }
  let(:user) { create(:user, role: role) }
  let(:token) { JwtService.encode(user_id: user.id.to_s) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/admin/reports' do
    context 'with read permission' do
      before do
        create(:permission,
          role: role,
          action: 'read',
          subject_class: 'Report',
          conditions: { user_id: 'user.id' }
        )
        create(:report, user: user)
        create(:report) # Other user's report
      end

      it 'returns only accessible reports' do
        get '/api/v1/admin/reports', headers: headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['reports'].count).to eq(1)
      end
    end

    context 'without permission' do
      it 'returns forbidden' do
        get '/api/v1/admin/reports', headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/admin/reports' do
    context 'with create permission' do
      before do
        create(:permission,
          role: role,
          action: 'create',
          subject_class: 'Report'
        )
      end

      it 'creates report' do
        post '/api/v1/admin/reports',
          params: { report: { title: 'Test', content: 'Content', report_type: 'financial' } },
          headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['report']['title']).to eq('Test')
      end
    end

    context 'without permission' do
      it 'returns forbidden' do
        post '/api/v1/admin/reports',
          params: { report: { title: 'Test', content: 'Content', report_type: 'financial' } },
          headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /api/v1/admin/reports/export' do
    context 'with export permission' do
      before do
        create(:permission,
          role: role,
          action: 'export',
          subject_class: 'Report',
          conditions: { user_id: 'user.id' }
        )
        create(:report, user: user)
      end

      it 'exports reports' do
        get '/api/v1/admin/reports/export', headers: headers
        expect(response).to have_http_status(:ok)
        expect(response.headers['Content-Type']).to include('text/csv')
      end
    end

    context 'without permission' do
      it 'returns forbidden' do
        get '/api/v1/admin/reports/export', headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
```

### Step 13: Create Factories

```ruby
# spec/factories/reports.rb
FactoryBot.define do
  factory :report do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    report_type { %w[financial event user].sample }
    association :user
  end
end
```

## Testing the Implementation

### 1. Run Seeds
```bash
rails db:seed
```

### 2. Test in Console

```ruby
rails console

# Create users with different roles
admin = User.find_by(role: Role.find_by(name: 'admin'))
organizer = User.find_by(role: Role.find_by(name: 'organizer'))

# Create reports
report1 = Report.create!(title: 'Admin Report', content: 'Content', report_type: 'financial', user: admin)
report2 = Report.create!(title: 'Organizer Report', content: 'Content', report_type: 'event', user: organizer)

# Test abilities
admin_ability = Ability.new(admin)
admin_ability.can?(:read, report1)  # => true
admin_ability.can?(:read, report2)  # => true

organizer_ability = Ability.new(organizer)
organizer_ability.can?(:read, report1)  # => false (not their report)
organizer_ability.can?(:read, report2)  # => true (their report)

# Test accessible_by
Report.accessible_by(admin_ability).count      # => 2 (all reports)
Report.accessible_by(organizer_ability).count  # => 1 (only their report)
```

### 3. Test API Endpoints

```bash
# Get JWT token
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"organizer@example.com","password":"password"}'

# Extract token from response
TOKEN="your_jwt_token_here"

# Test index (should only return user's reports)
curl -X GET http://localhost:3000/api/v1/admin/reports \
  -H "Authorization: Bearer $TOKEN"

# Test create
curl -X POST http://localhost:3000/api/v1/admin/reports \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"report":{"title":"My Report","content":"Content here","report_type":"event"}}'

# Test export (premium organizer only)
curl -X GET http://localhost:3000/api/v1/admin/reports/export \
  -H "Authorization: Bearer $TOKEN"
```

### 4. Run Tests

```bash
# Run all tests
rspec

# Run specific tests
rspec spec/models/ability_spec.rb
rspec spec/requests/api/v1/admin/reports_spec.rb
```

## Summary Checklist

- ✅ Model created with proper associations
- ✅ Permissions defined in seed data
- ✅ Seeds run successfully
- ✅ Ability class handles permissions automatically
- ✅ Controller extends BaseController with authorization
- ✅ Routes configured
- ✅ Service layer created
- ✅ Form object for validation
- ✅ Serializer with permission checks
- ✅ MongoDB search support added
- ✅ Tests written and passing
- ✅ API endpoints tested manually

## Key Takeaways

1. **Automatic Authorization**: `load_and_authorize_resource` handles most cases
2. **Condition Support**: Use `user_id: 'user.id'` for ownership checks
3. **accessible_by**: Filters collections by user abilities
4. **Custom Actions**: Use `authorize!` for non-CRUD actions
5. **Test Coverage**: Test each role's permissions thoroughly
6. **Serializers**: Include ability checks in API responses

---

**See [README.md](./README.md) for complete documentation**
