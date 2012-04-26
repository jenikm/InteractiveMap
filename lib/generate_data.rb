module GenerateData
  require 'faker'

  def self.truncate_data
    Order.destroy_all
  end

  def self.generate_data
    index_to_column = lambda{|index| case index;when 0: :seller_zip_code;when 1: :seller_country;when 2: :image_url;when 3: :title; when 4: :price_cents; when 5: :status end}
    lines = IO.readlines(File.join(RAILS_ROOT, "lib", "seed_data.txt")).
               map{|x| Hash[ *x.split("||||").
               map(&:strip).each_with_index.
               map{|y,i| [index_to_column.call(i), y] }.flatten ]}
      #Generate 100 orders
    100.times do
      order = Order.new(:status => Order::VALID_STATUSES.at(rand(Order::VALID_STATUSES.length)))

      #Generate random number of items
      (rand(20) + 1).times do |i|
        attributes = lines.at(rand(lines.length)).merge(:status => OrderItem::VALID_STATUSES.at(rand(OrderItem::VALID_STATUSES.length)))
        order.order_items.build attributes
      end

      #Find all items that were paid
      items = order.order_items.select{|i| i.shipped_by_seller? }
      number_to_be_shipped_by_seller = rand(items.length)

      #Make some items shipped by seller
      items[0..number_to_be_shipped_by_seller].each do |item|
        item.order_item_tracking_numbers.build(:tracking_number => Faker::Company.name.hash.abs, :carrier => "USPS")
      end

      items = order.order_items.select{|i| i.shipped_to_customer? }
      number_to_be_shipped = rand(items.length)
      items.each do |i|
        i.shipments.build(:tracking_number => Faker::Company.name.hash.abs, :carrier => "USPS", :service => ["EMS", "PRIORITY"].at(rand(2)))
      end
      order.save!
    end
    GenerateData.assign_random_tracking_numbers
  end

  def self.assign_random_tracking_numbers
    tracking_numbers = IO.readlines(File.join(RAILS_ROOT, "lib", "tracking_numbers.txt")).map(&:strip)
    Shipment.all.each do |shipment|
      shipment.update_attribute :tracking_number, tracking_numbers[(rand * tracking_numbers.length).to_i]
    end
  end
end



