class CreateOrderItems < ActiveRecord::Migration
  def self.up
    create_table :order_items do |t|
      t.integer :order_id
      t.string :title
      t.integer :price_cents
      t.integer :status
      t.string :image_url
      t.string :seller_zip_code
      t.string :seller_country

      t.timestamps
    end
  end

  def self.down
    drop_table :order_items
  end
end
