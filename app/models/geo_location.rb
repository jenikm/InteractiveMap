class GeoLocation < ActiveRecord::Base
  attr_accessor :virtual

  before_save lambda{|me| raise "Cannot Save Virtual" if me.virtual}

  #Currently tailored for resolving information for:
  #Ebay -> Google API -> geo
  #emspost -> zip code to city name resolver -> Google API -> geo
  def self.find_geolocation(options)
    geolocation = GeoLocation.find(:first, :conditions => options)
    if geolocation 
      if geolocation.unresolvable
        return nil
      else
        return geolocation
      end
    end
  
    #Resolve to geocoordnates using various methods
    coordinates = nil
    if options[:country_name] == "Russia" and options[:postal_code]
      result = open("http://enotpoiskun.ru/tools/mapbyindex/?query=#{options[:postal_code]}").read.match(/new GLatLng\((\d+\.\d+),(\d+\.\d+)\)/)
      if result and result[1] and result[2]
        coordinates = {"lat" => result[1], "lng" => result[2]}
        options.merge!(coordinates)
      end
    end
    unless coordinates
      address = options.values.join " "
      puts address 
      rsp = ActiveSupport::JSON.decode(open("http://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(address)},&sensor=false").read)
      coordinates = rsp["results"].andand[0].andand["geometry"].andand["location"]
      if coordinates and coordinates["lat"] and coordinates["lng"]
        options.merge!(coordinates)
      else
        options.merge!(:unresolvable => true)
      end
    end
    GeoLocation.create! options
  end
end
