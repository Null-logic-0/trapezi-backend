class Review < ApplicationRecord
  belongs_to :user
  belongs_to :food_place

  validates :rating, inclusion: { in: 1..5 }, presence: true
  validates :comment, length: { maximum: 200 }, presence: true
end
