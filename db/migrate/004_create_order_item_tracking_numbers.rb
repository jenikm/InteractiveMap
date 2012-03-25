class CreateOrderItemTrackingNumbers < ActiveRecord::Migration
  def self.up
    create_table :order_item_tracking_numbers do |t|
      t.string :tracking_number
      t.string :carrier
      t.integer :order_item_id

      t.timestamps
    end
  end

  def self.down
    drop_table :order_item_tracking_numbers
  end
end
