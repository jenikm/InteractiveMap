class AddGeoLocationIdToOrderItem < ActiveRecord::Migration
  def self.up
    add_column :order_items, :seller_geo_location_id, :integer
    add_column :shipment_tracking_logs, :shipment_tracking_log_id, :integer
  end

  def self.down
    remove_column :shipment_tracking_logs, :shipment_tracking_log_id
    remove_column :order_items, :seller_geo_location_id
  end
end
