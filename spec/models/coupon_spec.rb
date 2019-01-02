require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of :code }
    it { should validate_uniqueness_of :code }
    it { should validate_presence_of :status }
    it { should validate_presence_of :coupon_type }
  end
  describe 'relationships' do
    it { should belong_to :user }
    it { should have_one :order }
  end
end
