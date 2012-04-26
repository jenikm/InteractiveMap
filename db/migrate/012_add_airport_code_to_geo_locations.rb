class AddAirportCodeToGeoLocations < ActiveRecord::Migration
  def self.up
    add_column :geo_locations, :airport_code, :string
  end

  def self.down
    remove_column :geo_locations, :airport_code
  end
end
