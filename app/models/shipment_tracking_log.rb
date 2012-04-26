class ShipmentTrackingLog < ActiveRecord::Base
  belongs_to :shipment
  belongs_to :geo_location, :class_name => "GeoLocation", :foreign_key => "shipment_geo_location_id"

  def geocode
    options = {}
    raw_address = address_description_blob
    if raw_address.include?("Соединенные Штаты Америки") or raw_address.downcase.include?("united states") or raw_address.include?(" US ")
      options[:country_name] = "United States"
    end
    options[:postal_code] = postal_code
    if raw_address.downcase.include? "Russia" 
      options[:country_name] = "Russia"
    end
    options[:city] = raw_address.split(" ").select{|c| c.length >=5}.first
    
    options[:country_name] ||= "Russia"
    
    if raw_address.include? "USORDA"
      options[:airport_code] = "ORD"
    end

    self.geo_location = GeoLocation.find_geolocation options
    self.save!
    self
  end

end
