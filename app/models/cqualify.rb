class Cqualify < ActiveRecord::Base
  set_table_name "cqualify"
  set_primary_key "qcode"
  
  def full_name
    [longpre,qualify].join(" ").strip
  end
end
