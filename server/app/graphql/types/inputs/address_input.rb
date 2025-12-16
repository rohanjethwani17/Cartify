module Types
  module Inputs
    class AddressInput < Types::BaseInputObject
      argument :first_name, String, required: false
      argument :last_name, String, required: false
      argument :company, String, required: false
      argument :address1, String, required: false
      argument :address2, String, required: false
      argument :city, String, required: false
      argument :province, String, required: false
      argument :country, String, required: false
      argument :zip, String, required: false
      argument :phone, String, required: false
    end
  end
end
