require 'securerandom'

class CouponController < ApplicationController
  before_action :restrict_access

  def create
    code = SecureRandom.hex(3)
    coupon_type = coupon_type_params["coupon"]
    if coupon_type == '10% off order'
      discount = 0.1
    elsif coupon_type == '20% off order'
      discount = 0.2
    end
    user = User.find(coupon_type_params["id"])
    coupon_params = { code: code, coupon_type: coupon_type, discount: discount, user: user}
    Coupon.create(coupon_params)
    flash[:coupon_code] = "Created #{coupon_type} coupon code: #{code}"
    if current_user.merchant?
      redirect_to dashboard_path
    else
      redirect_to admin_merchant_path(user)
    end
  end

  def destroy
    coupon = Coupon.find(params[:id])
    coupon.update(status: 'Cancelled')
    if current_user.merchant?
      redirect_to dashboard_path
    else
      user = coupon.user
      redirect_to admin_merchant_path(user)
    end
  end

  def restrict_access
    render file: 'errors/not_found', status: 404 unless current_user && (current_merchant? || current_admin?)
  end


  private

  def coupon_type_params
    params.permit('coupon', 'id')
  end
end
