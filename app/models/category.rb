class Category < ActiveRecord::Base
  acts_as_tree :order => "text"
  has_many :products
#  acts_as_nested_set :order => "text"
end
