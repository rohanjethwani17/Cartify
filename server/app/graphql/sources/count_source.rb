module Sources
  class CountSource < GraphQL::Dataloader::Source
    def initialize(model_class, column)
      @model_class = model_class
      @column = column
    end
    
    def fetch(ids)
      counts = @model_class
        .where(@column => ids)
        .group(@column)
        .count
      
      ids.map { |id| counts[id] || 0 }
    end
  end
end
