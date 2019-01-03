require 'securerandom'

class CouponController < ApplicationController
  before_action :restrict_access

  def create
    code = SecureRandom.hex(3)
    coupon_type = coupon_type_params["coupon"]
    user = current_user
    coupon_params = { code: code, coupon_type: coupon_type, user: user}
    Coupon.create(coupon_params)
    flash[:coupon_code] = "Created #{coupon_type} coupon code: #{code}"
    redirect_to dashboard_path
  end

  def restrict_access
    render file: 'errors/not_found', status: 404 unless current_user && current_merchant?
  end

  private

  def coupon_type_params
    params.permit('coupon')
  end
end
