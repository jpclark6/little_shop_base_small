class Profile::OrdersController < ApplicationController
  before_action :require_default_user, only: :index

  def index
    @orders = current_user.orders
  end

  def valid_coupon?(coupon)
    coupon && coupon.status == 'Active'
  end

  def create
    coupon = Coupon.find_by(code: session[:coupon_code])
    if valid_coupon?(coupon)
      discount = coupon.discount
      coupons = coupon
      coupon.update(status: 'Used')
      order = Order.create(user: current_user, status: :pending, coupons: [coupons])
    else
      discount = 0
      order = Order.create(user: current_user, status: :pending)
    end
    @cart.items.each do |item|
      if coupon && item.merchant_id == coupon.user_id
        price = item.price - item.price * discount
      else
        price = item.price
      end
      order.order_items.create!(
        item: item,
        price: price,
        quantity: @cart.count_of(item.id),
        fulfilled: false)
    end
    session[:cart] = nil
    session[:coupon_code] = nil
    @cart = Cart.new({})
    flash[:success] = "You have successfully checked out!"

    redirect_to profile_path
  end

  def show
    @order = Order.find(params[:id])
  end

  def destroy
    order = Order.find(params[:id])
    if order.status == 'pending'
      order.order_items.each do |oi|
        if oi.fulfilled
          item = Item.find(oi.item_id)
          item.inventory += oi.quantity
          item.save
          oi.fulfilled = false
          oi.save
        end
      end
      order.status = :cancelled
      order.save
    end
    if current_admin?
      user = order.user
      redirect_to admin_user_order_path(user, order)
    else
      redirect_to profile_order_path(order)
    end
  end

  private

  def require_default_user
    render file: 'errors/not_found', status: 404 unless current_user && current_user.default?
  end
end
