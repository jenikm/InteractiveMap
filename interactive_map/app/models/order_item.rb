class OrderItem < ActiveRecord::Base
  belongs_to :order
  has_and_belongs_to_many :shipments
  has_many :order_item_tracking_numbers, :dependent => :destroy
  
  VALID_STATUSES        = [1,2,3,4,5].freeze

  def self.grouped_by_status_for_select
    #all(:select => "status,count(1) AS total", :group => "status").map{|i| {:name => "#{i.status_name} (#{i.total})", :id => i.status}}
    groups = {} 
    all.each do |item|
      if groups[item.status]
        groups[item.status][:ids] << item.id
      else
        groups[item.status] = {:name => item.status_name, :ids => [item.id]}
      end
    end
    array_groups = []
    groups.each do |k,v|
      if[:ids]
        array_groups << {:name => "#{ v[:name] } (#{ v[:ids].length })", :id => v[:ids].join(",")}
      end
    end
    array_groups
  end

  def paid?
    status == 1
  end

  def shipped_by_seller?
    status == 2
  end
  
  def arrived_from_seller
    status == 3
  end

  def shipped_to_customer?
    status == 4
  end

  def delivered_to_customer?
    status == 5
  end

  def status_name
    case status
      when 0: "Awaiting processing"
      when 1: "Paid to seller"
      when 2: "Shipped by seller"
      when 3: "Arrived from seller"
      when 4: "Shipped to customer"
      when 5: "Delivered to cuustomer"
      else "Error"
    end 
  end

end
