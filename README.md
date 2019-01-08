# LITTLE SHOP EXTENSIONS

For a final solo project I worked on some extensions for a pre-made Little Shop code base. I worked on adding coupon functionality as well as some graphs to display some stats.

See the original Little Shop for instillation instructions, required versions, dependencies, and the database structure.

The graphs were completed using D3, a javascript library that stands for 'Data Driven Documents'. Using D3 allows the client to display data using SVG in HTML. This information is called using ajax requests and could theoretically be modified to dynamically update on the screen even if the browser page isn't refreshed. This project only implemented basic functionality however, with some interaction capability on the bar chart.

The coupon functionality uses single use coupon codes generated by 'securerandom'. This generates a 3-byte hex code which can only be generated by merchants and admins for either 10% off an order or 20% off an order. On the merchant dashboard they can view the coupons they have generated in order to see which ones have been used, cancelled, or are still active. This can be given to a user to user during checkout. Once a coupon is entered the user can keep shopping. The shopping cart also displays the discount, which is applicable for the merchant who generated the coupon's items only.

Here is a code snippet of the coupon model to see how a coupon is generated in the database given a coupon type and merchant object.

```
class Coupon < ApplicationRecord
  validates_presence_of :code, :coupon_type, :status, :discount
  validates_uniqueness_of :code

  belongs_to :order, optional: true
  belongs_to :user

  enum status: ["Active", "Used", "Cancelled"]

  def self.create_coupon(coupon_type, user)
    code = SecureRandom.hex(3)
    discount = 0
    if coupon_type == '10% off order'
      discount = 0.1
    elsif coupon_type == '20% off order'
      discount = 0.2
    end
    coupon_params = { code: code, coupon_type: coupon_type, discount: discount, user: user}
    create(coupon_params)
  end
end
```
