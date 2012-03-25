class CreateShipments < ActiveRecord::Migration
  def self.up
    create_table :shipments do |t|
      t.string :tracking_number
      t.string :carrier
      t.string :service

      t.timestamps
    end
  end

  def self.down
    drop_table :shipments
  end
end
