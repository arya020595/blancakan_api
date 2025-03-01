class ReindexElasticsearchJob < ApplicationJob
  # Set the queue for this job
  queue_as :default

  # Perform the job
  # @param model_name [String] the name of the model
  # @param record_id [String] the ID of the record to reindex
  def perform(model_name, record_id)
    # Log the start of the job
    Rails.logger.info "ReindexElasticsearchJob started for #{model_name} with ID #{record_id}"

    # Convert the model name to a constant
    model = model_name.constantize

    # Find the record by ID
    record = model.find(record_id)

    if record
      # Reindex the record in Elasticsearch
      record.__elasticsearch__.index_document
      # Log the successful reindexing
      Rails.logger.info "Successfully reindexed #{model_name} with ID #{record_id}"
    else
      # Log a warning if the record is not found
      Rails.logger.warn "Record not found for #{model_name} with ID #{record_id}"
    end
  rescue StandardError => e
    # Log any errors that occur during reindexing
    Rails.logger.error "Error reindexing #{model_name} with ID #{record_id}: #{e.message}"
  end
end
