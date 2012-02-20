require 'composite_primary_keys'
class Pisinsig < ActiveRecord::Base
  set_table_name "pisinsig"
  set_primary_keys :id, :dccode, :dcyear
end
