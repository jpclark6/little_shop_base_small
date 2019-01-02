class CreateCoupons < ActiveRecord::Migration[5.1]
  def change
    create_table :coupons do |t|
      t.string :code
      t.string :coupon_type
      t.integer :status, default: 0

      t.timestamps
      t.references :user, foreign_key: true
      t.references :order, foreign_key: true
    end
  end
end
