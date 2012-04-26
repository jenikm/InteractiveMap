class CreateShipmentTrackingLogs < ActiveRecord::Migration
  def self.up
    create_table :shipment_tracking_logs do |t|
      t.integer :shipment_id
      t.text :address_description_blob
      t.string :postal_code
      t.text :status_name
      t.decimal :lat, :precision => 14, :scale => 8
      t.decimal :lng, :precision => 14, :scale => 8
      t.datetime :occurred_at
      t.boolean :geocode_failed, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :shipment_tracking_logs
  end
end
