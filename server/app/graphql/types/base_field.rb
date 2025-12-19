module Types
  class BaseField < GraphQL::Schema::Field
    argument_class Types::BaseArgument

    def initialize(*args, **kwargs, &block)
      # Add complexity based on whether it's a connection
      kwargs[:complexity] ||= kwargs[:connection] ? 10 : 1
      super
    end
  end
end
