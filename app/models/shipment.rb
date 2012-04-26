class Shipment < ActiveRecord::Base
  has_and_belongs_to_many :order_items
  has_many :shipment_tracking_logs, :dependent => :destroy do
    def geocode
      ActiveRecord::Base.transaction do
        self.select{|c| !c.geocode_failed and (!c.lat or !c.lng) }.each(&:geocode)
      end
    end
  end

  def ems_post_tracking_updates
    http = Net::HTTP.new('emspost.ru', 80)
    path = '/tracking.aspx/TrackOne'
    data = {:id => tracking_number}.to_json
    headers = {
      'Content-Type' => 'application/json',
      'Referer' => "http://emspost.ru/ru/tracking/?id=#{tracking_number}",
      'User-Agent' =>  'Mozilla/5.0 (X11; Linux i686) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.162 Safari/535.19'
    }
    resp, data = http.post(path, data, headers) 
    decoded = ActiveSupport::JSON.decode(data)
    return decoded["d"].andand["Operations"].andand.map do |entry|
      {:address_description_blob => entry["opAddressDescription"], :postal_code => entry["opAddressIndex"], 
       :occurred_at => entry["opDateTime"].to_time, :status_name => entry["opStatus"]}
    end || []
  end

  def russian_post_tracking_updates
    http = Net::HTTP.new('russianpost.ru', 80)
    cookies = nil
    data = open("http://www.russianpost.ru")
    data =(Hpricot(data)/"input").map{|i| [i['name'], i['value']]}.delete_if{|i| i[0].nil?}.map{|i| i.join("=")}.join(";")
    result = http.post("/", data, { 'Origin' => 'http://www.russianpost.ru',
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.165 Safari/535.19'})
    cookies = result.response['set-cookie']
    valid_cookies = []
    if cookies
      cookies.split(";").each do |cookie|
        cookie.split(",").each do |sub_cookie|
          if sub_cookie =~ /SessionId|uid/
            valid_cookies << sub_cookie.strip
          end
        end
      end
    end
    cookies = valid_cookies.join(";")
    path = "/resp_engine.aspx?BarCode=#{tracking_number}&Path=rp/servise/ru/home/postuslug/trackingpo"
    data = { "BarCode" => tracking_number,"searchsign" => 1}
    data = 'search1=&BarCode=EC689192889US&searchsign=1'
    headers = {
      'Origin' => 'http://www.russianpost.ru',
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.165 Safari/535.19',
      'Content-Type'=> 'application/x-www-form-urlencoded',
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Referer' => 'http://www.russianpost.ru/resp_engine.aspx?BarCode=EC689192889US&Path=rp/servise/ru/home/postuslug/trackingpo',
      'Cookie' => cookies
    }
    resp, data = http.post(path, data, headers) 
    
    content = []
    (Hpricot(data)/"table.pagetext/tbody/tr").each do |row|
      processed_column = {}
      (row/"td").each_with_index do |column, i|
        case i
          when 0:
            processed_column[:status_name] = column.inner_text
          when 1:
            processed_column[:occurred_at] = column.inner_text.to_time
          when 2:
            processed_column[:postal_code] = column.inner_text
          else
            processed_column[:address_description_blob] = [processed_column[:address_description_blob], column.inner_text].join(",")
        end
      end
      content << processed_column
    end
    content
  end

  def build_shipment_tracking_logs
    resp = self.ems_post_tracking_updates
    if resp.empty?
      resp = self.russian_post_tracking_updates
    end
    #log resp.inspect 
    #TODO add check prevent checking logs more oftne than 5 minutes

    resp.each_with_index do |log_entry, i|
      if log_entry[:country_name] == "United States" and log_enry[:postal_code].nil? or i.zero?
        log_entry[:postal_code] = "60077"
      end
      unless shipment_tracking_logs.all(:conditions => log_entry, :limit => 1).first
        shipment_tracking_logs.build log_entry
      end
    end
    shipment_tracking_logs.geocode
    self
  end

end
