require 'rails_helper'

describe 'as a merchant on my dashboard' do
  before(:each) do
    merchant = create(:merchant)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)
  end

  it 'can generate a one time use coupon code' do
    visit dashboard_path
    click_on 'Generate 10% Off Coupon'

    coupon = Coupon.last

    within(".alert") do
      expect(page).to have_content("10% off coupon code: #{coupon.code}")
    end
    within("#coupon-#{coupon.code}") do
      expect(page).to have_content(coupon.code)
      expect(page).to have_content("Active")
    end
  end
end
