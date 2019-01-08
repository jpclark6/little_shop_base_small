require 'rails_helper'

describe 'as a user' do
  before(:each) do
    @password = 'password'
    @user_email = 'user@email.com'
    @merchant_email = 'merchant@email.com'
    @merchant_email_2 = 'merchant_2@email.com'
    @user = create(:user, email: @user_email, password: @password)
    @merchant_1 = create(:merchant, email: @merchant_email, password: @password)
    @merchant_2 = create(:merchant, email: @merchant_email_2, password: @password)

    @item_1 = create(:item, user: @merchant_1, price: 10.0)
    @item_2 = create(:item, user: @merchant_1, price: 30.0)
    @item_3 = create(:item, user: @merchant_2, price: 5.0)

    visit login_path
    fill_in :email, with: @merchant_email
    fill_in :password, with: @password
    click_button 'Log in'
    visit dashboard_path
    click_on 'Generate 10% Off Coupon'
    @coupon_1 = Coupon.last
    visit dashboard_path
    click_on 'Generate 10% Off Coupon'
    @coupon_2 = Coupon.last
    click_on 'Log out'

    visit login_path
    fill_in :email, with: @user_email
    fill_in :password, with: @password
    click_button 'Log in'
    click_on 'Items'
    click_on @item_1.name
    click_button 'Add to Cart'
    click_on @item_2.name
    click_button 'Add to Cart'
    click_on @item_3.name
    click_button 'Add to Cart'
    click_on 'Cart:'
  end

  it 'can use a 10% off coupon to check out with discount to only merchants items' do
    total_pre_discount = @item_1.price + @item_2.price + @item_3.price
    expect(page).to have_content("Total: $#{total_pre_discount}")
    fill_in :coupon_code, with: @coupon_1.code
    click_button 'Apply'
    expect(current_path).to eq(cart_path)
    expect(page).to have_content('coupon applied')

    valid_items = @item_1.price + @item_2.price
    total = valid_items - 0.1 * valid_items + @item_3.price
    expect(page).to have_content("Total after discount: $#{total}")

    visit '/items'
    click_on @item_1.name
    click_button 'Add to Cart'
    visit cart_path

    valid_items = @item_1.price * 2 + @item_2.price
    total = valid_items.to_f - 0.1 * valid_items + @item_3.price
    expect(page).to have_content("Total after discount: $#{total}")

    click_button 'Check out'
    click_on 'Orders'
    order = Order.last

    within("#order-#{order.id}") do
      expect(page).to have_content("Total Cost: $#{total}")
    end
  end
  it 'can also generate and use 20% off coupons' do
    click_on 'Log out'
    visit login_path
    fill_in :email, with: @merchant_email
    fill_in :password, with: @password
    click_button 'Log in'
    visit dashboard_path
    click_on 'Generate 20% Off Coupon'
    @coupon_3 = Coupon.last
    click_on 'Log out'

    visit login_path
    fill_in :email, with: @user_email
    fill_in :password, with: @password
    click_button 'Log in'
    click_on 'Items'
    click_on @item_1.name
    click_button 'Add to Cart'
    click_on @item_2.name
    click_button 'Add to Cart'
    click_on @item_3.name
    click_button 'Add to Cart'
    click_on 'Cart:'

    total_pre_discount = @item_1.price + @item_2.price + @item_3.price
    expect(page).to have_content("Total: $#{total_pre_discount}")
    fill_in :coupon_code, with: @coupon_3.code
    click_button 'Apply'
    expect(current_path).to eq(cart_path)
    expect(page).to have_content('coupon applied')

    valid_items = @item_1.price + @item_2.price
    total = valid_items.to_f - 0.2 * valid_items + @item_3.price
    expect(page).to have_content("Total after discount: $#{total}")
    click_button 'Check out'
    click_on 'Orders'
    order = Order.last
    within("#order-#{order.id}") do
      expect(page).to have_content("Total Cost: $#{total}")
    end
  end
  it 'cannot enter another coupon after it is entered' do
    fill_in :coupon_code, with: @coupon_1.code
    click_button 'Apply'

    expect(page).to have_no_content('Coupon code')
  end
  it 'coupon is updated to used after coupon is used' do
    fill_in :coupon_code, with: @coupon_1.code
    click_button 'Apply'

    expect(@coupon_1.status).to eq('Active')
    click_button 'Check out'
    @coupon_1 = Coupon.find(@coupon_1.id)
    expect(@coupon_1.status).to eq('Used')
  end
  it 'a used coupon cannot be used again' do
    fill_in :coupon_code, with: @coupon_1.code
    click_button 'Apply'
    click_button 'Check out'
    click_on 'Items'
    click_on @item_1.name
    click_button 'Add to Cart'
    visit cart_path
    fill_in :coupon_code, with: @coupon_1.code
    click_button 'Apply'
    expect(page).to have_content("Coupon has already been used")
    expect(page).to have_content("Total: $#{@item_1.price}")
  end
  it 'a merchant can cancel an unused coupon' do
    fill_in :coupon_code, with: @coupon_1.code
    click_button 'Apply'
    click_button 'Check out'
    click_on 'Log out'

    visit login_path
    fill_in :email, with: @merchant_email
    fill_in :password, with: @password
    click_button 'Log in'
    visit dashboard_path

    expect(@coupon_2.status).to eq('Active')
    within("#coupon-#{@coupon_1.id}") do
      expect(page).to have_content('Used')
      expect(page).to have_no_content('Cancel coupon')
    end
    within("#coupon-#{@coupon_2.id}") do
      expect(page).to have_content('Active')
      expect(page).to have_button('Cancel coupon')
      click_on 'Cancel coupon'
    end
    expect(current_path).to eq(dashboard_path)
    within("#coupon-#{@coupon_2.id}") do
      expect(page).to have_content('Cancelled')
      expect(page).to have_no_content('Cancel coupon')
    end
    @coupon_2 = Coupon.find(@coupon_2.id)
    expect(@coupon_2.status).to eq('Cancelled')
  end
  it 'a cancelled coupon cannot be used' do
    click_on 'Log out'
    visit login_path
    fill_in :email, with: @merchant_email
    fill_in :password, with: @password
    click_button 'Log in'
    visit dashboard_path
    within("#coupon-#{@coupon_1.id}") do
      click_on 'Cancel coupon'
    end
    click_on 'Log out'

    visit login_path
    fill_in :email, with: @user_email
    fill_in :password, with: @password
    click_button 'Log in'
    click_on 'Items'
    click_on @item_1.name
    click_button 'Add to Cart'
    visit cart_path
    fill_in :coupon_code, with: @coupon_1.code
    click_button 'Apply'
    expect(page).to have_content("Coupon no longer valid")
    expect(page).to have_content("Total: $#{@item_1.price}")
  end
  it 'an invalid coupon code cannot be used' do
    fill_in :coupon_code, with: 'a4b2f1'
    click_button 'Apply'
    expect(page).to have_content("Coupon code not found")
    total_pre_discount = @item_1.price + @item_2.price + @item_3.price
    expect(page).to have_content("Total: $#{total_pre_discount}")
  end
  it 'can see the coupon used on an order' do
    fill_in :coupon_code, with: @coupon_1.code
    click_button 'Apply'
    click_button 'Check out'
    order = Order.last
    click_on 'Orders'
    click_on "Order ID #{order.id}"
    expect(page).to have_content("Coupon used successfully, code #{@coupon_1.code}, for #{@coupon_1.coupon_type}")
  end
  it 'does not see info about coupons on an order that did not use a coupon' do
    click_button 'Check out'
    order = Order.last
    click_on 'Orders'
    click_on "Order ID #{order.id}"
    expect(page).to have_no_content("Coupon used successfully")
  end
end
