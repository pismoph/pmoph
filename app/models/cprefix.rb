class Cprefix < ActiveRecord::Base
  set_table_name "cprefix"
  set_primary_key "pcode"
  has_many :pispersonels,
    :class_name => "Pispersonel",
    :foreign_key => "pcode"
end
