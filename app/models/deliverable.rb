
class Deliverable < ActiveRecord::Base
  acts_as_versioned
  has_attached_file :attachment
  belongs_to :uploader, :class_name=>'Person', :foreign_key => "uploader_id"
  belongs_to :team
  validates_attachment_presence :attachment
end
