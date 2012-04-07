# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 7) do

  create_table "accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_item_tracking_numbers", :force => true do |t|
    t.string   "tracking_number"
    t.string   "carrier"
    t.integer  "order_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_items", :force => true do |t|
    t.integer  "order_id"
    t.string   "title"
    t.integer  "price_cents"
    t.integer  "status"
    t.string   "image_url"
    t.string   "seller_zip_code"
    t.string   "seller_country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_items_shipments", :id => false, :force => true do |t|
    t.integer "order_item_id"
    t.integer "shipment_id"
  end

  create_table "orders", :force => true do |t|
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipments", :force => true do |t|
    t.string   "tracking_number"
    t.string   "carrier"
    t.string   "service"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
