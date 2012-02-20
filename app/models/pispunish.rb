require 'composite_primary_keys'
class Pispunish < ActiveRecord::Base
  set_table_name "pispunish"
  set_primary_keys :id,:forcedate
end
