class Coupon < ApplicationRecord
  validates_presence_of :code, :coupon_type, :status, :discount
  validates_uniqueness_of :code

  belongs_to :order, optional: true
  belongs_to :user

  enum status: ["Active", "Used", "Cancelled"]
end
