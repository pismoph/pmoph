class Cqualify < ActiveRecord::Base
  set_table_name "cqualify"
  set_primary_key "qcode"
  
  def full_name
    [longpre.to_s.strip,qualify.to_s.strip].join("").strip
  end
end
