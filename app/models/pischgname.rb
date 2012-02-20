require 'composite_primary_keys'
class Pischgname < ActiveRecord::Base
  set_table_name "pischgname"
  set_primary_keys :id,:chgno
end
