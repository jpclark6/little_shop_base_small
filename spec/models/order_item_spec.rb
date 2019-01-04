require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :quantity }
    it { should validate_numericality_of(:quantity).only_integer }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
  end

  describe 'relationships' do
    it { should belong_to :order }
    it { should belong_to :item }
  end

  describe 'class methods' do
    it '.sales_by_month' do
      @user_1 = create(:user, city: 'Denver', state: 'CO')
      @user_2 = create(:user, city: 'NYC', state: 'NY')
      @user_3 = create(:user, city: 'Seattle', state: 'WA')
      @user_4 = create(:user, city: 'Seattle', state: 'FL')

      @merchant_1, @merchant_2, @merchant_3 = create_list(:merchant, 3)
      @item_1 = create(:item, user: @merchant_1)
      @item_2 = create(:item, user: @merchant_2)
      @item_3 = create(:item, user: @merchant_3)

      @order_1 = create(:completed_order, user: @user_1)
      @oi_1 = create(:fulfilled_order_item, item: @item_1, order: @order_1, quantity: 100, price: 100, created_at: Time.now.change(month: 3), updated_at: Time.now.change(month: 3))
      @oi_5 = create(:order_item, item: @item_1, order: @order_1, quantity: 100, price: 100, created_at: Time.now.change(month: 3), updated_at: Time.now.change(month: 3))

      @order_2 = create(:completed_order, user: @user_2)
      @oi_2 = create(:fulfilled_order_item, item: @item_2, order: @order_2, quantity: 300, price: 300, created_at: Time.now.change(month: 5), updated_at: Time.now.change(month: 5))

      @order_3 = create(:completed_order, user: @user_3)
      @oi_3 = create(:fulfilled_order_item, item: @item_3, order: @order_3, quantity: 200, price: 200, created_at: Time.now.change(month: 7), updated_at: Time.now.change(month: 7))

      @order_4 = create(:completed_order, user: @user_4)
      @oi_4 = create(:fulfilled_order_item, item: @item_3, order: @order_4, quantity: 201, price: 200, created_at: Time.now.change(month: 8), updated_at: Time.now.change(month: 8))
      @oi_6 = create(:fulfilled_order_item, item: @item_3, order: @order_4, quantity: 100, price: 200, created_at: Time.now.change(month: 8), updated_at: Time.now.change(month: 8))

      expect(OrderItem.sales_by_month[1][:sales]).to eq(0)
      expect(OrderItem.sales_by_month[3][:sales]).to eq(10_000)
      expect(OrderItem.sales_by_month[5][:sales]).to eq(90_000)
      expect(OrderItem.sales_by_month[7][:sales]).to eq(40_000)
      expect(OrderItem.sales_by_month[8][:sales]).to eq(60_200)
      expect(OrderItem.sales_by_month[10][:sales]).to eq(0)
      expect(OrderItem.sales_by_month[12][:sales]).to eq(0)
    end
  end

  describe 'instance methods' do
    it '.subtotal' do
      oi = create(:order_item, quantity: 5, price: 3)

      expect(oi.subtotal).to eq(15)
    end
  end
end
