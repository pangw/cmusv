
class Deliverable < ActiveRecord::Base
  acts_as_versioned
  has_attached_file :attachment
end
