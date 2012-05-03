require 'open-uri'
class ActiveRecord::Base
  def log(text)
    @log ||= Logger.new(File.join(RAILS_ROOT, "log", "debug.log"))
    @log.info text
  end
  def self.first(*args)
    find :first, *args
  end

  def self.last(*args)
    options = args.pop || {}
    options.merge!({:order => "#{self.table_name}.id DESC"})
    args << options
    find :first, *args
  end

  def self.all(*args)
    find :all, *args
  end

  def self.random(limit=1)
    num_records = count
    result = all :offset => rand(count), :limit => limit
    result.length == 1 ? result.pop : result
  end

end

module ActionView
  module Helpers
    module TextHelper
      def truncate(text, length = 30, truncate_string = "...")
        if text.nil? then return end
        l = length - truncate_string.chars.to_a.size
        (text.chars.to_a.size > length ? text.chars.to_a[0...l].join + truncate_string : text).to_s
      end
    end
  end
end
