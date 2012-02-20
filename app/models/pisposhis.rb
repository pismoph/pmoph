require 'composite_primary_keys'
class Pisposhis < ActiveRecord::Base
  set_table_name "pisposhis"
  set_primary_keys :id,:historder
end
