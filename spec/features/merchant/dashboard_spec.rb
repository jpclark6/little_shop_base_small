require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'Merchant Dashboard page' do
  context 'as a merchant' do
    it 'should show my dashboard information' do
      merchant = create(:merchant)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

      visit dashboard_path

      expect(page).to have_content("Merchant Dashboard for #{merchant.name}")
      expect(page).to have_content(merchant.email)
      within '#address' do
        expect(page).to have_content(merchant.address)
        expect(page).to have_content("#{merchant.city}, #{merchant.state} #{merchant.zip}")
      end
      expect(page).to_not have_link('Edit Profile')
    end
    describe 'should show pending orders containing items I sell' do
      scenario "unless I don't have any..." do
        merchant = create(:merchant)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)
        visit dashboard_path

        within '#orders' do
          expect(page).to have_content("You don't have any pending orders to fulfill")
        end
      end
      scenario 'when I have orders pending' do
        merchant = create(:merchant)
        item = create(:item, user: merchant)
        orders = create_list(:order, 2)
        create(:order_item, order: orders[0], item: item, price: 1, quantity: 1)
        create(:order_item, order: orders[1], item: item, price: 1, quantity: 1)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

        visit dashboard_path
        within '#orders' do
          expect(page).to_not have_content("You don't have any pending orders to fulfill")
          orders.each do |order|
            within "#order-#{order.id}" do
              expect(page).to have_link("Order ID #{order.id}")
              expect(page).to have_content("Created: #{order.created_at}")
              expect(page).to have_content("Items in Order: #{order.my_item_count(merchant.id)}")
              expect(page).to have_content("Value of Order: #{number_to_currency(order.my_revenue_value(merchant.id))}")
            end
          end
        end
      end
    end
    describe 'when I have orders with items I sell' do
      it 'allows me to fulfill those parts of an order' do
        user = create(:user)
        merchant = create(:merchant)
        merchant_2 = create(:merchant)
        item = create(:item, user: merchant, inventory: 100)
        item_3 = create(:item, user: merchant)
        item_2 = create(:item, user: merchant_2)
        order = create(:order, user: user)
        create(:order_item, order: order, item: item, price: 1, quantity: 10)
        create(:order_item, order: order, item: item_2, price: 1, quantity: 1)
        create(:fulfilled_order_item, order: order, item: item_3, price: 1, quantity: 1)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

        visit item_path(item)
        expect(page).to have_content("In stock: 100")

        visit dashboard_path
        within "#order-#{order.id}" do
          click_link("Order ID #{order.id}")
        end

        expect(current_path).to eq(dashboard_order_path(order))
        within '#user-details' do
          expect(page).to have_content(user.name)
          expect(page).to have_content(user.address)
          expect(page).to have_content("#{user.city}, #{user.state} #{user.zip}")
        end
        within '#order-details' do
          expect(page).to_not have_css("#item-#{item_2.id}")
          within "#item-#{item_3.id}" do
            expect(page).to have_content("Fulfilled!")
            expect(page).to_not have_button('Fulfill Item')
          end

          within "#item-#{item.id}" do
            expect(page).to have_link(item.name)
            expect(page.find("#item-#{item.id}-image")['src']).to have_content(item.image)
            expect(page).to have_content("Price: #{number_to_currency(order.item_price(item.id))}")
            expect(page).to have_content("Quantity: #{order.item_quantity(item.id)}")
            expect(page).to have_button('Fulfill Item')
          end
          expect(page).to_not have_css("#item-#{item_2.id}")
          expect(page).to_not have_content(item_2.name)

          click_button 'Fulfill Item'
        end
        expect(current_path).to eq(dashboard_order_path(order))
        within "#item-#{item.id}" do
          expect(page).to have_content("Fulfilled!")
          expect(page).to_not have_button('Fulfill Item')
        end

        visit item_path(item)
        expect(page).to have_content("In stock: 90")
      end
      it 'blocks me from fulfilling an order if I lack inventory' do
        user = create(:user)
        merchant = create(:merchant)
        item = create(:item, user: merchant, inventory: 10)
        order = create(:order, user: user)
        create(:order_item, order: order, item: item, price: 1, quantity: 11)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

        visit dashboard_order_path(order)

        within "#item-#{item.id}" do
          expect(page).to_not have_button('Fulfill Item')
          expect(page).to have_content("Cannot fulfill, not enough inventory")
        end
      end
      it 'sets order as complete if I am the last merchant to fulfill items' do
        user = create(:user)
        merchant = create(:merchant)
        merchant_2 = create(:merchant)
        item_1 = create(:item, user: merchant, inventory: 100)
        item_3 = create(:item, user: merchant)
        item_2 = create(:item, user: merchant_2)
        order_1 = create(:order, user: user)
        order_2 = create(:order, user: user)
        create(:order_item, order: order_1, item: item_1, price: 1, quantity: 10)
        create(:fulfilled_order_item, order: order_1, item: item_2, price: 1, quantity: 1)
        create(:order_item, order: order_2, item: item_3, price: 1, quantity: 1)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

        visit dashboard_order_path(order_1)
        expect(page).to have_content("Status: pending")
        within "#item-#{item_1.id}" do
          click_button('Fulfill Item')
        end
        visit dashboard_order_path(order_1)
        expect(page).to have_content("Status: completed")

        visit dashboard_order_path(order_2)
        expect(page).to have_content("Status: pending")
        within "#item-#{item_3.id}" do
          click_button('Fulfill Item')
        end
        visit dashboard_order_path(order_1)
        expect(page).to have_content("Status: completed")
      end
    end
    describe 'should show some statistics' do
      before :each do
        user_1 = create(:user, city: 'Springfield', state: 'MO')
        user_2 = create(:user, city: 'Springfield', state: 'CO')
        user_3 = create(:user, city: 'Las Vegas', state: 'NV')
        user_4 = create(:user, city: 'Denver', state: 'CO')

        merchant = create(:merchant)
        @item_1, @item_2, @item_3, @item_4 = create_list(:item, 4, user: merchant, inventory: 20)

        @order_1 = create(:completed_order, user: user_1)
        @oi_1a = create(:fulfilled_order_item, order: @order_1, item: @item_1, quantity: 2, price: 100)

        @order_2 = create(:completed_order, user: user_1)
        @oi_1b = create(:fulfilled_order_item, order: @order_2, item: @item_1, quantity: 1, price: 80)

        @order_3 = create(:completed_order, user: user_2)
        @oi_2 = create(:fulfilled_order_item, order: @order_3, item: @item_2, quantity: 5, price: 60)

        @order_4 = create(:completed_order, user: user_3)
        @oi_3 = create(:fulfilled_order_item, order: @order_4, item: @item_3, quantity: 3, price: 40)

        @order_5 = create(:completed_order, user: user_4)
        @oi_4 = create(:fulfilled_order_item, order: @order_5, item: @item_4, quantity: 4, price: 20)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)
      end
      it 'shows top 5 items sold by quantity' do
        visit dashboard_path
        within '#statistics' do
          within '#top-5-items' do
            expect(page.all('.item')[0]).to have_content(@item_2.name)
            expect(page.all('.item')[1]).to have_content(@item_4.name)
            expect(page.all('.item')[2]).to have_content(@item_1.name)
            expect(page.all('.item')[3]).to have_content(@item_3.name)
          end
        end
      end
      it 'shows items sold vs remaining' do
        visit dashboard_path
        within '#statistics' do
          within '#quantity-sold' do
            expect(page).to have_content('You have sold 15 items out of 95 (15.79%)')
          end
          within '.pie-chart' do
            expect(page).to have_content('Sold Items')
            expect(page).to have_content('Remaining Items')
          end
        end
      end
      it 'shows top states where orders were shipped' do
        visit dashboard_path
        within '#statistics' do
          within '#top-3-states' do
            expect(page.all('.state')[0]).to have_content('CO, quantity shipped: 9')
            expect(page.all('.state')[1]).to have_content('MO, quantity shipped: 3')
            expect(page.all('.state')[2]).to have_content('NV, quantity shipped: 3')
          end
        end
      end
      it 'shows top cities where orders were shipped' do
        visit dashboard_path
        within '#statistics' do
          within '#top-3-cities' do
            expect(page.all('.city')[0]).to have_content('Springfield, CO, quantity shipped: 5')
            expect(page.all('.city')[1]).to have_content('Denver, CO, quantity shipped: 4')
            expect(page.all('.city')[2]).to have_content('Springfield, MO, quantity shipped: 3')
          end
        end
      end
      describe 'shows user who had most orders' do
        scenario 'when I have orders' do
          visit dashboard_path
          within '#statistics' do
            within '#most-ordering-user' do
              expect(page).to have_content('User Name 1, with 2 orders')
            end
          end
        end
        scenario 'or a friendly error when i have no orders' do
          sad_merchant = create(:merchant)
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(sad_merchant)
          visit dashboard_path
          within '#statistics' do
            within '#most-ordering-user' do
              expect(page).to have_content("You don't have any orders yet")
            end
          end
        end
      end
      describe 'shows user who had bought most items' do
        scenario 'when I have orders' do
          visit dashboard_path
          within '#statistics' do
            within '#most-items-user' do
              expect(page).to have_content('User Name 2, with 5 items')
            end
          end
        end
        scenario 'or a friendly error when i have no orders' do
          sad_merchant = create(:merchant)
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(sad_merchant)
          visit dashboard_path
          within '#statistics' do
            within '#most-items-user' do
              expect(page).to have_content("You don't have any orders yet")
            end
          end
        end
      end
      it 'shows three users by revenue' do
        visit dashboard_path
        within '#statistics' do
          within '#top-3-revenue-users' do
            expect(page.all('.user')[0]).to have_content('User Name 2, revenue: $300.00')
            expect(page.all('.user')[1]).to have_content('User Name 1, revenue: $280.00')
            expect(page.all('.user')[2]).to have_content('User Name 3, revenue: $120.00')
          end
        end
      end
    end
  end

  context 'as an admin' do
  end
end
