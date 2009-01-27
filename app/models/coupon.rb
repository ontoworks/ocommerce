class Coupon < Discount
#    ActiveRecord::Base
  MAX_VALUE = 40000
  MIN_VALUE = 0

  has_and_belongs_to_many :users

  before_create :clean_coupon

  def applies_to_order?(o)
    # o can be Order or Cart
    o.totalize_items > min_price && o.totalize_items < max_price
  end

  def is_current?
    Time.now.to_date < date_down
  end

  def percent_discount?
    discount_by.downcase == "percent"
  end

  def times_used
    users.count
  end

  def Coupon.generate_new_code
    code = ""
    6.times do                  # 6 random characters
      code << (rand(25) + 65).chr
    end
    2.times do                  # 2 random numbers at the end
      code << (rand(9) + 48).chr
    end
    return Coupon.generate_new_code if Coupon.code_already_used?(code)
    code
  end

  private
  def Coupon.code_already_used?(code)
    c = Coupon.find_by_code(code)
    c != nil
  end

  def clean_coupon
    self.max_price = MAX_VALUE if max_price.nil?
    self.min_price = MIN_VALUE if min_price.nil?
    self.use_times = 0 if use_times < 0
  end
end
