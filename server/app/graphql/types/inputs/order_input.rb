module Types
  module Inputs
    class OrderInput < Types::BaseInputObject
      argument :email, String, required: false
      argument :line_items, [Types::Inputs::LineItemInput], required: true
      argument :shipping_address, Types::Inputs::AddressInput, required: false
      argument :note, String, required: false
    end
  end
end
