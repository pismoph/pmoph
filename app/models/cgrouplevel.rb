class Cgrouplevel < ActiveRecord::Base
  set_table_name "cgrouplevel"
  set_primary_key "ccode"
    has_many :pisj18s,
    :class_name => "Pisj18",
    :foreign_key => "ccode"
end
