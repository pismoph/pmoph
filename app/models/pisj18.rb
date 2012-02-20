class Pisj18 < ActiveRecord::Base
  set_table_name "pisj18"
  set_primary_key "posid"
  belongs_to :csubdept,
    :class_name => "Csubdept",
    :foreign_key => "sdcode"
  belongs_to :cdept,
    :class_name => "Cdept",
    :foreign_key => "deptcode"
  belongs_to :cposition,
    :class_name => "Cposition",
    :foreign_key => "poscode"
  belongs_to :cgrouplevel,
    :class_name => "Cgrouplevel",
    :foreign_key => "c"
end
