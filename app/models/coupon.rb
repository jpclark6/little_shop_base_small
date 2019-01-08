require 'securerandom'

class Coupon < ApplicationRecord
  validates_presence_of :code, :coupon_type, :status, :discount
  validates_uniqueness_of :code

  belongs_to :order, optional: true
  belongs_to :user

  enum status: ["Active", "Used", "Cancelled"]

  def self.create_coupon(coupon_type, user)
    code = SecureRandom.hex(3)
    discount = 0
    if coupon_type == '10% off order'
      discount = 0.1
    elsif coupon_type == '20% off order'
      discount = 0.2
    end
    coupon_params = { code: code, coupon_type: coupon_type, discount: discount, user: user}
    create(coupon_params)
  end
end
