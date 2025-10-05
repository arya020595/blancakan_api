# Async Elasticsearch Indexing

## Overview

This implementation provides **non-blocking, resilient Elasticsearch indexing** that ensures your application remains operational even when Elasticsearch is unavailable.

## Architecture

### Design Pattern: Background Job Pattern

**Source:** "Enterprise Integration Patterns" by Gregor Hohpe & Bobby Woolf

```
User Request → MongoDB (Primary) → Response (Fast ✅)
                    ↓
            Background Job Queue
                    ↓
            Elasticsearch (Async)
```

### Benefits

1. **Non-blocking**: Create/update/delete operations succeed immediately
2. **Fault-tolerant**: Elasticsearch failures don't crash the application
3. **Retriable**: Jobs automatically retry with exponential backoff
4. **Better UX**: Users don't wait for indexing to complete
5. **Dual-source**: MongoDB for immediate search, Elasticsearch for advanced queries

## Implementation Details

### 1. Async Callbacks

**File:** `app/models/concerns/elasticsearch/base_searchable.rb`

```ruby
# Removed synchronous callbacks
# include Elasticsearch::Model::Callbacks  # ❌ This blocks requests

# Added async callbacks
after_commit :async_index_document, on: [:create, :update]
after_commit :async_delete_document, on: :destroy
```

**Reference:** "Elasticsearch: The Definitive Guide" (O'Reilly) - Chapter on Index Management recommends async indexing for production systems.

### 2. Error Handling Strategy

#### For Index Operations (Create/Update)

- Enqueues `ReindexElasticsearchJob`
- Logs warnings if job queuing fails
- **Never raises exceptions** - main operation succeeds

#### For Delete Operations

- Enqueues `ReindexElasticsearchJob` with 'delete' action
- Logs warnings if job queuing fails
- **Never raises exceptions** - main operation succeeds
- Job handles 404 errors as success (document already deleted)

**Reference:** Erlang/Elixir "Let It Crash" philosophy adapted for Ruby - prioritize main operation success.

### 3. Retry Strategy

**File:** `app/jobs/reindex_elasticsearch_job.rb`

```ruby
# Exponential backoff retry strategy
retry_on Elastic::Transport::Transport::Error,
         wait: :exponentially_longer,
         attempts: 5
```

**Retry Schedule:**

- Attempt 1: Immediate
- Attempt 2: +3 seconds
- Attempt 3: +15 seconds
- Attempt 4: +2 minutes
- Attempt 5: +10 minutes

**Reference:** "Sidekiq in Practice" - Exponential backoff is recommended for external service dependencies.

### 4. Smart Discard

```ruby
# Don't retry if record is deleted
discard_on Mongoid::Errors::DocumentNotFound
```

If a record is deleted before the job runs, we discard the job rather than retry.

## Configuration

### Enable/Disable Elasticsearch

```bash
# Disable Elasticsearch (useful for testing or maintenance)
export ELASTICSEARCH_ENABLED=false

# Enable Elasticsearch (default)
export ELASTICSEARCH_ENABLED=true
```

### Queue Configuration

Jobs are queued to the `:elasticsearch` queue for better organization:

```ruby
queue_as :elasticsearch
```

**Sidekiq Configuration:**

```yaml
# config/sidekiq.yml
:queues:
  - critical
  - default
  - elasticsearch # Lower priority than critical operations
  - mailers
```

## Usage Examples

### Example 1: Create Operation

```ruby
# Controller
role = Role.create!(name: "Admin", description: "Administrator role")
# ✅ Returns immediately - MongoDB saved
# 📤 Job queued: ReindexElasticsearchJob.perform_later("Role", role.id)

# Background (seconds later)
# 🔍 Elasticsearch indexed asynchronously
```

### Example 2: Elasticsearch Down

```ruby
# Elasticsearch is not running or unreachable

role = Role.create!(name: "Manager")
# ✅ Success! MongoDB saved
# ⚠️  Warning logged: "Failed to enqueue Elasticsearch indexing job"
# 📊 MongoDB search works immediately
# 🔄 When Elasticsearch comes back online, you can bulk reindex
```

### Example 3: Update Operation

```ruby
role = Role.find(id)
role.update!(name: "Senior Admin")
# ✅ Returns immediately
# 📤 Job queued for reindexing
# 🔄 Job retries if Elasticsearch is temporarily down
```

### Example 4: Delete Operation

```ruby
role.destroy!
# ✅ MongoDB delete succeeds immediately
# � Job queued: ReindexElasticsearchJob.perform_later("Role", role.id, "delete")
# 🔄 Background: Elasticsearch document deleted asynchronously
# 📝 If document doesn't exist in ES, job treats as success
```

## Monitoring

### Check Job Status

```ruby
# In Rails console
Sidekiq::Queue.new('elasticsearch').size
# => 0 (all jobs processed)

# Check failed jobs
Sidekiq::RetrySet.new.select { |job| job.queue == 'elasticsearch' }
```

### Check Elasticsearch Availability

```ruby
Role.elasticsearch_available?
# => true/false
```

### View Logs

```bash
# Check for Elasticsearch warnings
grep "Elasticsearch" log/production.log

# Check job processing
grep "ReindexElasticsearchJob" log/production.log
```

## Bulk Reindexing

If Elasticsearch was down for a period, you can bulk reindex:

```ruby
# Reindex all roles
Role.reindex_elasticsearch(force: true)

# Or all models
[Role, Category, Event, User].each do |model|
  model.reindex_elasticsearch(force: true)
end
```

## Testing

### Test with Elasticsearch Disabled

```ruby
# spec/models/role_spec.rb
describe 'async indexing' do
  before { ENV['ELASTICSEARCH_ENABLED'] = 'false' }
  after { ENV['ELASTICSEARCH_ENABLED'] = 'true' }

  it 'creates role without Elasticsearch' do
    expect {
      Role.create!(name: 'Test', description: 'Test role')
    }.not_to raise_error
  end
end
```

### Test Job Execution

```ruby
require 'rails_helper'

RSpec.describe ReindexElasticsearchJob do
  it 'indexes document in Elasticsearch' do
    role = create(:role)

    expect {
      described_class.perform_now('Role', role.id.to_s)
    }.not_to raise_error
  end

  it 'handles missing records gracefully' do
    expect {
      described_class.perform_now('Role', 'nonexistent_id')
    }.not_to raise_error
  end
end
```

## Trade-offs

### Advantages ✅

- **Resilience**: Application works even if Elasticsearch is down
- **Performance**: Faster response times (no waiting for indexing)
- **Reliability**: Automatic retries with exponential backoff
- **Observability**: Detailed logging at each step

### Considerations ⚠️

- **Eventual consistency**: Small delay between MongoDB save and Elasticsearch availability
- **Job queue dependency**: Requires Sidekiq or similar background job processor
- **Monitoring needed**: Should monitor failed jobs in production

## Best Practices

1. **Monitor job queues**: Set up alerts for growing Elasticsearch queue
2. **Health checks**: Regularly check Elasticsearch availability
3. **Bulk reindex capability**: Have a process to bulk reindex if needed
4. **Log analysis**: Review warning logs to detect Elasticsearch issues early
5. **Dual search**: Keep MongoDB search as primary, Elasticsearch as enhancement

## References

1. **Elasticsearch: The Definitive Guide** (O'Reilly)

   - Chapter 38: "Index Management" - Async indexing patterns

2. **Enterprise Integration Patterns** by Hohpe & Woolf

   - "Background Job" pattern for async processing

3. **Sidekiq in Practice**

   - Exponential backoff for external service dependencies
   - Queue prioritization strategies

4. **Rails Background Jobs Best Practices**

   - Error handling and retry strategies
   - Job idempotency considerations

5. **Erlang/OTP Design Principles**
   - "Let It Crash" philosophy adapted for Ruby
   - Supervisor patterns for fault tolerance

## Migration from Synchronous

If you had synchronous indexing before:

```ruby
# Before (blocking)
include Elasticsearch::Model::Callbacks

# After (non-blocking)
# Callbacks are now in BaseSearchable
# No changes needed in individual model files
```

All models that include `Elasticsearch::BaseSearchable` automatically get async indexing!

## Troubleshooting

### Jobs Not Processing

```bash
# Check Sidekiq is running
ps aux | grep sidekiq

# Check queue
bundle exec rails console
Sidekiq::Queue.new('elasticsearch').size
```

### Elasticsearch Connection Issues

```ruby
# Check connection
Role.__elasticsearch__.client.info

# Check index exists
Role.__elasticsearch__.index_exists?

# Recreate index
Role.__elasticsearch__.create_index!(force: true)
```

### High Memory Usage

If too many jobs queue up:

```ruby
# Process in batches
Role.find_each(batch_size: 100) do |role|
  ReindexElasticsearchJob.perform_later('Role', role.id.to_s)
  sleep 0.1 # Throttle
end
```
