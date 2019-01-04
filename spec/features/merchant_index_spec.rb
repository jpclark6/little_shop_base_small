require 'rails_helper'

RSpec.describe 'Merchant Index Page', type: :feature do
  before :each do
    @merchant = create(:merchant)
    @inactive_merchant = create(:inactive_merchant)
  end
  context 'as a non-admin user' do
    it 'should show all active merchants' do
      visit merchants_path

      within "#merchant-#{@merchant.id}" do
        expect(page).to have_content("#{@merchant.name}, #{@merchant.city} #{@merchant.state}")
        expect(page).to have_content(@merchant.created_at)
      end
      expect(page).to_not have_content(@inactive_merchant.name)
    end
    describe 'it shows statistics' do
      before :each do
        @user_1 = create(:user, city: 'Denver', state: 'CO')
        @user_2 = create(:user, city: 'NYC', state: 'NY')
        @user_3 = create(:user, city: 'Seattle', state: 'WA')
        @user_4 = create(:user, city: 'Seattle', state: 'FL')

        @merchant_1 = create(:merchant, name: 'Merchant Name 1')
        @merchant_2 = create(:merchant, name: 'Merchant Name 2')
        @merchant_3 = create(:merchant, name: 'Merchant Name 3')

        @item_1 = create(:item, user: @merchant_1)
        @item_2 = create(:item, user: @merchant_2)
        @item_3 = create(:item, user: @merchant_3)

        @order_1 = create(:completed_order, user: @user_1)
        @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 100, price: 100, created_at: 10.minutes.ago, updated_at: 9.minute.ago)

        @order_2 = create(:completed_order, user: @user_2)
        @oi_2 = create(:fulfilled_order_item, item: @item_2, order: @order_2, quantity: 300, price: 300, created_at: 2.days.ago, updated_at: 1.minute.ago)

        @order_3 = create(:completed_order, user: @user_3)
        @oi_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3, quantity: 200, price: 200, created_at: 10.minutes.ago, updated_at: 5.minute.ago)

        @order_4 = create(:completed_order, user: @user_4)
        @oi_4 = create(:fulfilled_order_item, item: @item_3, order: @order_4, quantity: 201, price: 200, created_at: 10.minutes.ago, updated_at: 5.minute.ago)
      end

=begin
- top 3 states where any orders were shipped
NY, WA, FL
- top 3 cities where any orders were shipped (Springfield, MI should not be grouped with Springfield, CO)
NYC, Seattle WA, Seattle FL
- top 3 biggest orders by quantity of items
2, 3, 4
=end
      it 'shows top 3 merchants by revenue' do
        visit merchants_path
        within '#statistics' do
          within '#top-3-revenue-merchants' do
            expect(page.all('.merchant')[0]).to have_content('Merchant Name 2, Revenue: $90,000')
            expect(page.all('.merchant')[1]).to have_content('Merchant Name 3, Revenue: $80,200')
            expect(page.all('.merchant')[2]).to have_content('Merchant Name 1, Revenue: $10,000')
          end
        end
      end
      it 'shows top 3 merchants by fastest average fulfillment time' do
        visit merchants_path
        within '#statistics' do
          within '#top-3-fulfilling-merchants' do
            expect(page.all('.merchant')[0]).to have_content('Merchant Name 1, Average Fulfillment Time: 1 minute')
            expect(page.all('.merchant')[1]).to have_content('Merchant Name 3, Average Fulfillment Time: 5 minutes')
            expect(page.all('.merchant')[2]).to have_content('Merchant Name 2, Average Fulfillment Time: 1 day, 23 hours, 59 minutes')
          end
        end
      end
      it 'shows worst 3 merchants by slowest average fulfillment time' do
        visit merchants_path
        within '#statistics' do
          within '#bottom-3-fulfilling-merchants' do
            expect(page.all('.merchant')[0]).to have_content('Merchant Name 2, Average Fulfillment Time: 1 day, 23 hours, 59 minutes')
            expect(page.all('.merchant')[1]).to have_content('Merchant Name 3, Average Fulfillment Time: 5 minutes')
            expect(page.all('.merchant')[2]).to have_content('Merchant Name 1, Average Fulfillment Time: 1 minute')
          end
        end
      end
      it 'shows top 3 states where orders were shipped' do
        visit merchants_path
        within '#statistics' do
          within '#top-3-states-shipped' do
            expect(page.all('.state')[0]).to have_content('CO, 1 order')
            expect(page.all('.state')[1]).to have_content('FL, 1 order')
            expect(page.all('.state')[2]).to have_content('NY, 1 order')
          end
        end
      end
      it 'shows top 3 cities where orders were shipped' do
        visit merchants_path
        within '#statistics' do
          within '#top-3-cities-shipped' do
            expect(page.all('.city')[0]).to have_content('Denver CO, 1 order')
            expect(page.all('.city')[1]).to have_content('NYC NY, 1 order')
            expect(page.all('.city')[2]).to have_content('Seattle FL, 1 order')
          end
        end
      end
      it 'shows top orders by quantity of items' do
        visit merchants_path
        within '#statistics' do
          within '#top-3-quantity-orders' do
            expect(page.all('.order')[0]).to have_content('User Name 2 bought 300 items in one order')
            expect(page.all('.order')[1]).to have_content('User Name 4 bought 201 items in one order')
            expect(page.all('.order')[2]).to have_content('User Name 3 bought 200 items in one order')
          end
        end
      end
    end
    it 'shows sales by month' do
      visit merchants_path
      within '#statistics' do
        within '.sales-by-month' do
          expect(page).to have_content('Sales by Month')
          expect(page).to have_content('January')
          expect(page).to have_content('July')
          expect(page).to have_content('December')
        end
      end
    end
  end
  context 'as an admin user' do
    before :each do
      admin = create(:admin)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)
    end
    it 'should show all merchants with enable/disable buttons' do
      visit merchants_path

      within "#merchant-#{@merchant.id}" do
        expect(page).to have_link(@merchant.name)
        expect(page).to have_content("#{@merchant.name}, #{@merchant.city} #{@merchant.state}")
        expect(page).to have_content(@merchant.created_at)
        expect(page).to have_button('Disable')
      end
      within "#merchant-#{@inactive_merchant.id}" do
        expect(page).to have_link(@inactive_merchant.name)
        expect(page).to have_content("#{@inactive_merchant.name}, #{@inactive_merchant.city} #{@inactive_merchant.state}")
        expect(page).to have_content(@inactive_merchant.created_at)
        expect(page).to have_button('Enable')
      end
    end
    it 'should show an admin user a merchant dashboard' do
      visit merchants_path

      within "#merchant-#{@merchant.id}" do
        click_link(@merchant.name)
      end

      expect(current_path).to eq(admin_merchant_path(@merchant))
      expect(page).to have_content("Merchant Dashboard for #{@merchant.name}")
    end
  end
end
