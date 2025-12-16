class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  
  # Use UUID as default primary key
  self.implicit_order_column = :created_at
end
