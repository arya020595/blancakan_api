class ReindexElasticsearchJob < ApplicationJob
  # Queue configuration
  queue_as :elasticsearch

  # Retry strategy - based on Sidekiq best practices
  # Reference: "Sidekiq in Practice" recommends exponential backoff for external services
  # Retries: 0min, 3min, 15min, 2hr, 10hr (5 attempts total)
  retry_on Elastic::Transport::Transport::Error, wait: :exponentially_longer, attempts: 5
  retry_on Faraday::ConnectionFailed, wait: :exponentially_longer, attempts: 5

  # Don't retry if record is not found - it's been deleted
  discard_on Mongoid::Errors::DocumentNotFound do |job, error|
    HelperLogger.warn(
      'Document not found for reindexing - likely deleted',
      klass: job.class.name,
      extra: {
        model_name: job.arguments.first,
        record_id: job.arguments.second,
        error: error.message
      }
    )
  end

  # @param model_name [String] the name of the model class
  # @param record_id [String] the ID of the record
  # @param action [String] 'index' (default) or 'delete'
  def perform(model_name, record_id, action = 'index')
    @model_name = model_name
    @record_id = record_id
    @action = action.to_s

    log_start

    case @action
    when 'delete'
      delete_from_elasticsearch
    when 'index'
      index_to_elasticsearch
    else
      handle_unknown_action
    end
  rescue Elastic::Transport::Transport::Error => e
    handle_connection_error(e)
    raise # Re-raise to trigger retry
  rescue StandardError => e
    handle_unexpected_error(e)
    # Don't re-raise - let job complete to avoid infinite retries
  end

  private

  attr_reader :model_name, :record_id, :action

  def log_start
    HelperLogger.info(
      "Starting Elasticsearch #{@action}",
      klass: self.class.name,
      extra: { model_name: @model_name, record_id: @record_id, action: @action, attempt: executions }
    )
  end

  def delete_from_elasticsearch
    model = @model_name.constantize
    client = model.__elasticsearch__.client
    index_name = model.__elasticsearch__.index_name

    client.delete(index: index_name, id: @record_id)
    log_success('Successfully deleted document from Elasticsearch')
  rescue Elastic::Transport::Transport::Error => e
    raise unless document_not_found?(e)

    log_success('Document not found in Elasticsearch (already deleted)')

    # Re-raise to trigger retry
  end

  def index_to_elasticsearch
    model = @model_name.constantize
    record = model.find(@record_id)

    record.__elasticsearch__.index_document
    log_success('Successfully indexed document to Elasticsearch')
  end

  def handle_unknown_action
    HelperLogger.warn(
      "Unknown action: #{@action}",
      klass: self.class.name,
      extra: { action: @action, model_name: @model_name, record_id: @record_id }
    )
  end

  def handle_connection_error(error)
    HelperLogger.warn(
      'Elasticsearch connection error - will retry',
      klass: self.class.name,
      extra: {
        model_name: @model_name,
        record_id: @record_id,
        action: @action,
        attempt: executions,
        error: error.message
      }
    )
  end

  def handle_unexpected_error(error)
    HelperLogger.error(
      'Unexpected error during Elasticsearch operation',
      klass: self.class.name,
      extra: {
        model_name: @model_name,
        record_id: @record_id,
        action: @action,
        error: error.class.name,
        message: error.message,
        backtrace: error.backtrace.first(5)
      }
    )
  end

  def document_not_found?(error)
    error.message.include?('404') || error.message.include?('not_found')
  end

  def log_success(message)
    HelperLogger.info(
      message,
      klass: self.class.name,
      extra: { model_name: @model_name, record_id: @record_id, action: @action }
    )
  end
end
