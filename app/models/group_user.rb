class GroupUser < ActiveRecord::Base
  has_many :users
end
