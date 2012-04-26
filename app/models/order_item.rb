class OrderItem < ActiveRecord::Base
  require 'open-uri'
  belongs_to :order
  belongs_to :seller_geo_location, :class_name => "GeoLocation", :foreign_key => "seller_geo_location_id"
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

  def self.status_name(status)
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

  def status_name
    OrderItem.status_name status 
  end

  def geocode_seller
    address = {}
    seller_country_clean = seller_country.to_s.strip
    if seller_country_clean == "US" and seller_zip_code =~ /^\d{5}$/
      address[:postal_code] = seller_zip_code.to_s.strip
    end
    if seller_country_clean == "US"
      address[:country_name] = "United States"
    else
      address[:country_name] = seller_country_clean
    end

    self.seller_geo_location = GeoLocation.find_geolocation address
  end

  def self.br_office_geolocation
    GeoLocation.new(:lat => 42.019078, :lng => -87.714531, :virtual => true)
  end

  def seller_br_office_midway_geo_location
    if seller_geo_location
      GeoLocation.new(:lat => seller_geo_location.lat + (OrderItem.br_office_geolocation.lat - seller_geo_location.lat) / 2,  :lng => seller_geo_location.lng + (OrderItem.br_office_geolocation.lng - seller_geo_location.lng) / 2, :virtual => true)
    else
      nil
    end
  end

  def get_geolocation_path
    paths = {}
    paths[:seller] = self.seller_geo_location if status >= 1
    paths[:midway] = self.seller_br_office_midway_geo_location if status >= 2
    #paths[:br_office] = OrderItem.br_office_geolocation if status >= 3
    paths
  end

end
