class CreateDeliverables < ActiveRecord::Migration
  def self.up
    create_table :deliverables do |t|
      t.integer :team_id
      t.integer :uploader_id
      t.string :name
      t.string :comments
      t.integer :task_number
      t.integer :course_number_id
      t.boolean :is_individual

      t.timestamps
    end
  end

  def self.down
    drop_table :deliverables
  end
end
