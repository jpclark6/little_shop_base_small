require 'securerandom'

class CouponsController < ApplicationController
  before_action :require_admin_or_merchant, only: [:create, :destroy]
  before_action :require_default_user_or_visitor, only: [:update]

  def create
    code = SecureRandom.hex(3)
    coupon_type = coupon_type_params["coupon"]
    discount = 0
    if coupon_type == '10% off order'
      discount = 0.1
    elsif coupon_type == '20% off order'
      discount = 0.2
    end
    user = User.find(coupon_type_params["id"])
    coupon_params = { code: code, coupon_type: coupon_type, discount: discount, user: user}
    Coupon.create(coupon_params)
    flash[:success] = "Created #{coupon_type} coupon code: #{code}"
    if current_user.merchant?
      redirect_to dashboard_path
    else
      redirect_to admin_merchant_path(user)
    end
  end

  def update
    coupon_code = params["coupon_code"]
    session[:coupon_code] = coupon_code
    coupon = Coupon.find_by(code: coupon_code)
    if coupon
      case coupon.status
      when 'Active'
        flash[:success] = "#{coupon.coupon_type} coupon applied successfully"
      when 'Used'
        flash[:error] = "Coupon has already been used"
      when 'Cancelled'
        flash[:error] = "Coupon no longer valid"
      end
    else
      flash[:error] = "Coupon code not found"
    end
    redirect_to cart_path
  end

  def destroy
    coupon = Coupon.find(params[:id])
    coupon.update(status: 'Cancelled')
    flash[:error] = "Coupon #{coupon.code} cancelled"
    if current_user.merchant?
      redirect_to dashboard_path
    else
      user = coupon.user
      redirect_to admin_merchant_path(user)
    end
  end

  private

  def coupon_type_params
    params.permit('coupon', 'id')
  end

  def require_default_user_or_visitor
    render file: 'errors/not_found', status: 404 unless !current_user || (current_user && current_user.default?)
  end

  def require_admin_or_merchant
    render file: 'errors/not_found', status: 404 unless current_user && (current_merchant? || current_admin?)
  end
end
