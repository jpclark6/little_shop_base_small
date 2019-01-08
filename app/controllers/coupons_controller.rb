class CouponsController < ApplicationController
  before_action :require_admin_or_merchant, only: [:create, :destroy]
  before_action :require_default_user_or_visitor, only: [:update]

  def create
    coupon_type = coupon_type_params["coupon"]
    user = User.find(coupon_type_params["id"])
    coupon = Coupon.create_coupon(coupon_type, user)
    flash[:success] = "Created #{coupon.coupon_type} coupon code: #{coupon.code}"
    if current_user.merchant?
      redirect_to dashboard_path
    else
      redirect_to admin_merchant_path(user)
    end
  end

  def update
    coupon_code = params["coupon_code"]
    coupon = Coupon.find_by(code: coupon_code)
    if coupon
      case coupon.status
      when 'Active'
        flash[:coupon] = "#{coupon.coupon_type} coupon applied successfully"
        session[:coupon_code] = coupon_code
      when 'Used'
        flash[:alert] = "Coupon has already been used"
      when 'Cancelled'
        flash[:alert] = "Coupon no longer valid"
      end
    else
      flash[:alert] = "Coupon code not found"
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
