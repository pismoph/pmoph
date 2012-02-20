require 'composite_primary_keys'
class Pistrainning < ActiveRecord::Base
  set_table_name "pistrainning"
  set_primary_keys :id,:tno
end
