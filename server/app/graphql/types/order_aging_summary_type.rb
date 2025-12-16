module Types
  class OrderAgingSummaryType < Types::BaseObject
    field :zero_to_one_day, Integer, null: false
    field :two_to_three_days, Integer, null: false
    field :four_to_seven_days, Integer, null: false
    field :eight_plus_days, Integer, null: false
  end
end
