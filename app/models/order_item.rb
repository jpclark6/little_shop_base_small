class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  def self.sales_by_month
    OrderItem.select("date_trunc('month', updated_at) as month, sum(quantity * price) as total_month")
              .where(fulfilled: true)
              .group('month')
              .order('month')
  end

  def self.formatted_sales_by_month
    hash_by_month = sales_by_month.reduce({}) do |hash, month|
      hash[month.month.strftime("%m").to_i] = month.total_month
      hash
    end
    months = Date::MONTHNAMES
    formatted = months.map.with_index do |month, i|
      if hash_by_month.keys.index(i)
        hash_by_month.values[hash_by_month.keys.index(i)]
      else
        0
      end
    end
    formatted.shift
    formatted
  end

  def subtotal
    quantity * price
  end
end
