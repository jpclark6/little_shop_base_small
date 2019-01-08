require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of :code }
    it { should validate_uniqueness_of :code }
    it { should validate_presence_of :status }
    it { should validate_presence_of :discount }
    it { should validate_presence_of :coupon_type }
  end
  describe 'relationships' do
    it { should belong_to :user }
    it { should belong_to :order }
  end
  describe 'class methods' do
    describe '.create_coupon' do
      before(:each) do
        @user = create(:user, email: 'user', password: 'password')
      end
      it '10% off' do
        coupon_type = '10% off order'
        coupon = Coupon.create_coupon(coupon_type, @user)
        expect(coupon.user).to eq(@user)
        expect(coupon.discount).to eq(0.1)
      end
      it '20% off' do
        coupon_type = '20% off order'
        coupon = Coupon.create_coupon(coupon_type, @user)
        expect(coupon.user).to eq(@user)
        expect(coupon.discount).to eq(0.2)
      end
      it 'other invalid type' do
        coupon_type = '30% off order'
        coupon = Coupon.create_coupon(coupon_type, @user)
        expect(coupon.user).to eq(@user)
        expect(coupon.discount).to eq(0)
      end
    end
  end
end
