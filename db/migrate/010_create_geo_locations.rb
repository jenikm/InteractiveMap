class CreateGeoLocations < ActiveRecord::Migration
  def self.up
    create_table :geo_locations do |t|
      t.decimal :lat, :precision => 18, :scale => 8
      t.decimal :lng, :precision => 18, :scale => 8
      t.string :postal_code
      t.string :country_name
      t.string :city
      t.boolean :unresolvable, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :geo_locations
  end
end
