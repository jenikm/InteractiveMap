class GenerateOrderItemsShipments < ActiveRecord::Migration
  def self.up
    create_table :order_items_shipments, :id => false do |t|
      t.integer :order_item_id
      t.integer :shipment_id
    end
  end

  def self.down
    drop_table :order_items_shipments
  end
end
