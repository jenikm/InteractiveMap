class Order < ActiveRecord::Base
  has_many :order_items, :dependent => :destroy
  
  VALID_STATUSES        = [1,2,3,4].freeze

  def purchased?
    self.order_items.select{|i| i.purchased?}
  end

  def number
    "#{id}-#{self.created_at.to_i}"
  end

end
