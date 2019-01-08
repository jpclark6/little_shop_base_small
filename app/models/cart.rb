class Cart
  attr_reader :contents

  def initialize(initial_contents)
    @contents = initial_contents || Hash.new(0)
  end

  def total_count
    @contents.values.sum
  end

  def count_of(item_id)
    @contents[item_id.to_s].to_i
  end

  def add_item(item_id)
    @contents[item_id.to_s] ||= 0
    @contents[item_id.to_s] += 1
  end

  def subtract_item(item_id)
    @contents[item_id.to_s] -= 1
    @contents.delete(item_id.to_s) if @contents[item_id.to_s] == 0
  end

  def remove_all_of_item(item_id)
    @contents.delete(item_id.to_s)
  end

  def items
    @contents.keys.map do |item_id|
      Item.includes(:user).find(item_id)
    end
  end

  def subtotal(item_id)
    item = Item.find(item_id)
    item.price * count_of(item_id)
  end

  def grand_total
    @contents.keys.map do |item_id|
      subtotal(item_id)
    end.sum
  end

  def find_discount(coupon)
    qualifying_amount = 0
    if coupon && coupon.status == 'Active'
      qualifying_amount = @contents.keys.reduce(0) do |sum, item_id|
        if Item.find(item_id).merchant_id == coupon.user_id
          sum += subtotal(item_id)
        end
        sum
      end
    else
      qualifying_amount = 0
    end
    discount = qualifying_amount * coupon.discount
    return discount
  end

  def coupon_grand_total(coupon)
    grand_total - find_discount(coupon)
  end
end
