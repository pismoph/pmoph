class Cdept < ActiveRecord::Base
  set_table_name "cdept"
  set_primary_key "deptcode"
  has_many :pisj18s,
    :class_name => "Pisj18",
    :foreign_key => "deptcode"
end
