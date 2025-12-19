module Sources
  class AssociationSource < GraphQL::Dataloader::Source
    def initialize(association_name)
      @association_name = association_name
    end

    def fetch(records)
      # Preload the association for all records
      ActiveRecord::Associations::Preloader.new(
        records: records,
        associations: @association_name
      ).call

      # Return the association for each record
      records.map { |record| record.public_send(@association_name) }
    end
  end
end
