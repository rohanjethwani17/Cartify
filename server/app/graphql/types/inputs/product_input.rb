module Types
  module Inputs
    class ProductInput < Types::BaseInputObject
      argument :title, String, required: true
      argument :description, String, required: false
      argument :status, String, required: false
      argument :product_type, String, required: false
      argument :vendor, String, required: false
      argument :variants, [Types::Inputs::VariantInput], required: false
    end
  end
end
