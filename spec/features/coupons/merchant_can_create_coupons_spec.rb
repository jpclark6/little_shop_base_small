require 'rails_helper'

describe 'as a merchant on my dashboard' do
  before(:each) do
    @password = 'password'
    @user_email = 'user@email.com'
    @merchant_email = 'merchant@email.com'
    @user = create(:user, email: @user_email, password: @password)
    @merchant = create(:merchant, email: @merchant_email, password: @password)

    visit login_path
    fill_in :email, with: @merchant_email
    fill_in :password, with: @password
    click_button 'Log in'
  end

  it 'can generate a one time use coupon code' do
    visit dashboard_path
    click_on 'Generate 10% Off Coupon'

    expect(current_path).to eq(dashboard_path)
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
end
