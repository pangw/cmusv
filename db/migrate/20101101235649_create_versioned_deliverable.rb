class CreateVersionedDeliverable < ActiveRecord::Migration
  def self.up
    Deliverable.create_versioned_table
  end

  def self.down
    Deliverable.drop_versioned_table
  end
end
