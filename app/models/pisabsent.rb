require 'composite_primary_keys'
class Pisabsent < ActiveRecord::Base
  set_table_name "pisabsent"
  set_primary_keys :id, :abcode, :begindate
end
