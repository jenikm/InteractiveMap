class LoadSeedData < ActiveRecord::Migration
  def self.up
    GenerateData.generate_data
  end

  def self.down
    GenerateData.truncate_data
  end
end
