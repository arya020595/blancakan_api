# frozen_string_literal: true

module V1
  class CategoryForm
    include ActiveModel::Model

    # Define accessible attributes
    attr_accessor :name, :description, :is_active, :parent_id

    def initialize(params = {})
      # Automatically assigns values to attr_accessors using ActiveModel::Model's initializer
      super(params)
      @contract = ::V1::Category::CategoryContract.new
    end

    def valid?
      @validation_result = @contract.call(attributes)
      @validation_result.success?
    end

    # Returns ActiveModel::Errors with contract errors.
    #
    # Example:
    #   form = V1::CategoryForm.new(name: "a")
    #   form.valid? # => false
    #   form.errors.to_hash
    #   # => { name: ["must be at least 3 characters"] }
    def errors
      raise 'You must call `valid?` before accessing `errors`' unless @validation_result

      ActiveModel::Errors.new(self).tap do |am_errors|
        @validation_result.errors.to_h.each do |field, messages|
          Array(messages).each { |msg| am_errors.add(field, msg) }
        end
      end
    end

    def attributes
      {
        name: name,
        description: description,
        is_active: is_active,
        parent_id: parent_id
      }
    end
  end
end
