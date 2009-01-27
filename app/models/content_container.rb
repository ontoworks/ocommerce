class ContentContainer < ActiveRecord::Base
  acts_as_tree :order => name
  has_many :contents
end
