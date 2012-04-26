class AddSellerLatSellerLngToOrderItems < ActiveRecord::Migration
  def self.up
    add_column :order_items, :seller_lat, :integer
    add_column :order_items, :seller_lng, :integer
  end

  def self.down
    remove_column :order_items, :seller_lng
    remove_column :order_items, :seller_lat
  end
end
