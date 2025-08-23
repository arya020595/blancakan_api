class ReindexElasticsearchJob < ApplicationJob
  # Set the queue for this job
  queue_as :default

  # Perform the job
  # @param model_name [String] the name of the model
  # @param record_id [String] the ID of the record to reindex
  def perform(model_name, record_id)
    # Log the start of the job
    HelperLogger.info(
      'ReindexElasticsearchJob started',
      klass: self.class.name,
      extra: { model_name: model_name, record_id: record_id }
    )

    # Convert the model name to a constant
    model = model_name.constantize

    # Find the record by ID
    record = model.find(record_id)

    if record
      # Reindex the record in Elasticsearch
      record.__elasticsearch__.index_document
      # Log the successful reindexing
      HelperLogger.info(
        'Successfully reindexed',
        klass: self.class.name,
        extra: { model_name: model_name, record_id: record_id }
      )
    else
      # Log a warning if the record is not found
      HelperLogger.warn(
        'Record not found',
        klass: self.class.name,
        extra: { model_name: model_name, record_id: record_id }
      )
    end
  rescue StandardError => e
    # Log any errors that occur during reindexing
    HelperLogger.error(
      "Error reindexing: #{e.message}",
      klass: self.class.name,
      extra: { model_name: model_name, record_id: record_id, error: e.class.name, backtrace: e.backtrace }
    )
  end
end
