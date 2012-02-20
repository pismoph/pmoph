#require 'composite_primary_keys'
class Piseducation < ActiveRecord::Base
  set_table_name "piseducation"
  #set_primary_keys :id,:eorder
  attr_accessible  :id,:eorder,:status,:enddate,:regisno,:qcode,:ecode,:macode,:institute,:cocode,:flag,:maxed,:refno
end
