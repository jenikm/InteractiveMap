class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :status
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
