module Types
  module Inputs
    class VariantInput < Types::BaseInputObject
      argument :title, String, required: true
      argument :sku, String, required: false
      argument :price, Float, required: true
      argument :compare_at_price, Float, required: false
    end
  end
end
