require 'rails_helper'

RSpec.describe ReindexElasticsearchJob, type: :job do
  let(:user) { create(:user) } # Assuming you have a User factory

  describe '#perform' do
    it 'reindexes the record in Elasticsearch' do
      # Stub the index_document method on the Elasticsearch proxy
      allow_any_instance_of(User).to receive_message_chain(:__elasticsearch__, :index_document).and_return(true)

      # Perform the job
      ReindexElasticsearchJob.perform_now('User', user.id.to_s)

      # Verify that the index_document method was called
      expect(user.__elasticsearch__).to have_received(:index_document)
    end

    it 'logs an error if an exception occurs' do
      allow(User).to receive(:find).and_raise(Mongoid::Errors::DocumentNotFound.new(User, user.id))
      expect(Rails.logger).to receive(:error).with(/Error reindexing User with ID #{user.id}/)
      ReindexElasticsearchJob.perform_now('User', user.id.to_s)
    end

    it 'logs a warning if the record is not found' do
      allow(User).to receive(:find).and_return(nil)
      expect(Rails.logger).to receive(:warn).with(/Record not found for User with ID #{user.id}/)
      ReindexElasticsearchJob.perform_now('User', user.id.to_s)
    end
  end
end
