require 'rails_helper'

RSpec.describe Cart do
  it '.total_count' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })
    expect(cart.total_count).to eq(5)
  end

  it '.count_of' do
    cart = Cart.new({})
    expect(cart.count_of(5)).to eq(0)

    cart = Cart.new({
      '2' => 3
    })
    expect(cart.count_of(2)).to eq(3)
  end

  it '.add_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.add_item(1)
    cart.add_item(2)
    cart.add_item(3)

    expect(cart.contents).to eq({
      '1' => 3,
      '2' => 4,
      '3' => 1
      })
  end

  it '.subtract_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.subtract_item(1)
    cart.subtract_item(1)
    cart.subtract_item(2)

    expect(cart.contents).to eq({
      '2' => 2
      })
  end

  it '.remove_all_of_item' do
    cart = Cart.new({
      '1' => 2,
      '2' => 3
    })

    cart.remove_all_of_item(1)

    expect(cart.contents).to eq({
      '2' => 3
    })
  end

  it '.items' do
    item_1, item_2 = create_list(:item, 2)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)

    expect(cart.items).to eq([item_1, item_2])
  end

  it '.subtotal' do
    item_1 = create(:item)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)

    expect(cart.subtotal(item_1.id)).to eq(item_1.price * cart.total_count)
  end

  it '.grand_total' do
    item_1, item_2 = create_list(:item, 2)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)
    cart.add_item(item_2.id)
    cart.add_item(item_2.id)

    expect(cart.grand_total).to eq(cart.subtotal(item_1.id) + cart.subtotal(item_2.id))
  end

  it '.apply_coupon' do
    merchant_1 = create(:merchant, email: 'm1', password: 'password')
    merchant_2 = create(:merchant, email: 'm2', password: 'password')
    item_1 = create(:item, user: merchant_1, price: 10.0)
    item_2 = create(:item, user: merchant_1, price: 30.0)
    item_3 = create(:item, user: merchant_2, price: 5.0)
    coupon_1 = Coupon.create(code: 'aaaaaa', coupon_type: '10% off order', discount: 0.1, user: merchant_1)
    coupon_2 = Coupon.create(code: 'bbbbbb', coupon_type: '20% off order', discount: 0.2, user: merchant_2)
    coupon_3 = Coupon.create(code: 'cccccc', coupon_type: '20% off order', discount: 0.2, user: merchant_1, status: 1)
    coupon_4 = Coupon.create(code: 'dddddd', coupon_type: '20% off order', discount: 0.2, user: merchant_1, status: 2)
    cart = Cart.new({})
    cart.add_item(item_1.id)
    cart.add_item(item_2.id)
    cart.add_item(item_3.id)
    expected_coupon_1_discount = (item_1.price + item_2.price) * 0.1
    expected_coupon_2_discount = (item_3.price) * 0.2
    expected_coupon_3_discount = 0
    expected_coupon_4_discount = 0

    expect(cart.apply_coupon(coupon_1)).to eq (expected_coupon_1_discount)
    expect(cart.apply_coupon(coupon_2)).to eq (expected_coupon_2_discount)
    expect(cart.apply_coupon(coupon_3)).to eq (expected_coupon_3_discount)
    expect(cart.apply_coupon(coupon_4)).to eq (expected_coupon_4_discount)
  end
end
