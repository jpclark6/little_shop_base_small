class CartController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_action :require_default_user_or_visitor

  def index
    @items = @cart.items
    @coupon = Coupon.find_by(code: session[:coupon_code])
  end

  def update
    coupon_code = params["coupon_code"]
    session[:coupon_code] = coupon_code
    coupon = Coupon.find_by(code: coupon_code)
    if coupon
      case coupon.status
      when 'Active'
        flash[:coupon] = "#{coupon.coupon_type} coupon applied successfully"
      when 'Used'
        flash[:coupon] = "Coupon has already been used"
      when 'Cancelled'
        flash[:coupon] = "Coupon no longer valid"
      end
    else
      flash[:coupon] = "Coupon code not found"
    end
    redirect_to cart_path
  end

  def add_item
    add_item_to_cart(params[:id])
    redirect_to items_path
  end

  def add_more_item
    add_item_to_cart(params[:id])
    redirect_to cart_path
  end

  def remove_more_item
    item = Item.find(params[:id])
    @cart.subtract_item(item.id)
    flash[:success] = "You have removed 1 package of #{item.name} from your cart, new quantity is #{@cart.count_of(item.id)}"
    session[:cart] = @cart.contents
    redirect_to cart_path
  end

  def remove_all_of_item
    item = Item.find(params[:id])
    @cart.remove_all_of_item(item.id)
    flash[:success] = "You have removed all packages of #{item.name} from your cart"
    session[:cart] = @cart.contents
    redirect_to cart_path
  end

  def destroy
    session[:cart] = nil
    @cart = Cart.new(session[:cart])
    redirect_to cart_path
  end

  private

  def require_default_user_or_visitor
    render file: 'errors/not_found', status: 404 unless !current_user || (current_user && current_user.default?)
  end

  def add_item_to_cart(item_id)
    item = Item.find(item_id)
    @cart.add_item(item.id)
    flash[:success] = "You have #{pluralize(@cart.count_of(item.id), 'package')} of #{item.name} in your cart"
    session[:cart] = @cart.contents
  end
end
