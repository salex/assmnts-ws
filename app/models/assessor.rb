class Assessor < ActiveRecord::Base
  belongs_to :assessment
  has_many :scores
end
