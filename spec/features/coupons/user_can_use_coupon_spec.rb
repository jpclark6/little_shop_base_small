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

    @item_1 = create(:item, user: @merchant_1, price: 10)
    @item_2 = create(:item, user: @merchant_1, price: 30)
    @item_3 = create(:item, user: @merchant_2, price: 5)

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

  it 'can use a 10% off coupon to check out adding many items' do
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
    total = valid_items - 0.1 * valid_items + @item_3.price
    expect(page).to have_content("Total after discount: $#{total}")
  end
  it 'cannot enter another coupon after it is entered' do
    fill_in :coupon_code, with: @coupon_1.code
    click_button 'Apply'

    expect(page).to have_no_content('Coupon code')
  end
  it 'coupon is updated to used after coupon is used' do
  end
  it 'a used coupon cannot be used again' do
  end
  it 'a merchant can cancel a coupon' do
  end
  it 'a cancelled coupon cannot be used' do
  end
  it 'an invalid coupon code cannot be used' do
  end

end

# a7d920
