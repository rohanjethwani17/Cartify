module Types
  module Inputs
    class LineItemInput < Types::BaseInputObject
      argument :variant_id, ID, required: true
      argument :quantity, Integer, required: true
    end
  end
end
