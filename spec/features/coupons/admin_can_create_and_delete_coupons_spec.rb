require 'rails_helper'

describe 'as a merchant on my dashboard' do
  before(:each) do
    @password = 'password'
    @user_email = 'user@email.com'
    @merchant_email = 'merchant@email.com'
    @admin_email = 'admin@email.com'
    @user = create(:user, email: @user_email, password: @password)
    @merchant = create(:merchant, email: @merchant_email, password: @password)
    @admin = create(:admin, email: @admin_email, password: @password)

    visit login_path
    fill_in :email, with: @admin_email
    fill_in :password, with: @password
    click_button 'Log in'
    click_on 'Merchants'
    click_on @merchant.name
  end

  it 'can generate a one time use coupon code' do
    click_on 'Generate 10% Off Coupon'

    expect(current_path).to eq(admin_merchant_path(@merchant))
    coupon = Coupon.last

    within(".alert") do
      expect(page).to have_content("10% off order coupon code: #{coupon.code}")
    end
    within("#coupon-#{coupon.id}") do
      expect(page).to have_content(coupon.code)
      expect(page).to have_content("Active")
    end
    click_on 'Generate 10% Off Coupon'
    coupon = Coupon.last

    within(".alert") do
      expect(page).to have_content("10% off order coupon code: #{coupon.code}")
    end
    within("#coupon-#{coupon.id}") do
      expect(page).to have_content(coupon.code)
      expect(page).to have_content("Active")
    end
  end
  it 'can cancel coupons' do
    click_on 'Generate 10% Off Coupon'
    coupon = Coupon.last

    within("#coupon-#{coupon.id}") do
      expect(page).to have_content('Active')
      expect(page).to have_button('Cancel coupon')
      click_on 'Cancel coupon'
    end
    expect(current_path).to eq(admin_merchant_path(@merchant))
    within("#coupon-#{coupon.id}") do
      expect(page).to have_content('Cancelled')
      expect(page).to have_no_content('Cancel coupon')
    end
  end
end
